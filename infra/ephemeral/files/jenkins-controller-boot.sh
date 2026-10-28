# Jenkins controller boot script. Terraform puts a shebang and these variables above it:
#   CONFIG_COMMIT (full commit SHA that contains jenkins/), DEPLOY_ROLE_NAME
# Never add `set -x` or echo a secret: this script's output goes to the cloud-init log.
set -euo pipefail
export HOME=/root
export DEBIAN_FRONTEND=noninteractive
export AWS_DEFAULT_REGION=us-east-1

RAW="https://raw.githubusercontent.com/dmncfrncsc/cicd-pipeline-vprofile/${CONFIG_COMMIT}/jenkins"
JHOME=/var/lib/jenkins
SECRETS_DIR="$JHOME/init-secrets"
PIM_VERSION=2.15.0

fail_closed() {
  echo "p3: $1. Stopping Jenkins and refusing to continue." >&2
  systemctl stop jenkins || true
  systemctl disable jenkins || true
  rm -f "$SECRETS_DIR/agent-secret"
  exit 1
}
http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$@" || true; }

retry() {
  local n=1
  until "$@"; do
    if [ "$n" -ge 10 ]; then
      echo "p3: giving up after 10 attempts: $1" >&2
      return 1
    fi
    echo "p3: attempt $n failed: $1. Retrying in 15 seconds." >&2
    n=$((n + 1))
    sleep 15
  done
}

apt_install() {
  apt-get update && apt-get install -y "$@"
}

install_awscli() {
  aws --version > /dev/null 2>&1 && return 0
  rm -rf /tmp/awscli-install && mkdir -p /tmp/awscli-install \
    && curl --proto "=https" --tlsv1.2 -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscli-install/awscliv2.zip \
    && unzip -q /tmp/awscli-install/awscliv2.zip -d /tmp/awscli-install \
    && /tmp/awscli-install/aws/install \
    && aws --version
}

# 1. Install packages. policy-rc.d (exit 101) stops the Jenkins package from starting itself.
printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
retry apt_install fontconfig openjdk-21-jre-headless curl unzip
retry install_awscli
install -d -m 0755 /etc/apt/keyrings
retry curl --proto "=https" --tlsv1.2 -fsSL -o /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
retry apt_install jenkins=2.580.1
rm -f /usr/sbin/policy-rc.d

# 2. Fetch the config files from the pinned commit.
install -d -m 0700 -o jenkins -g jenkins "$SECRETS_DIR"
install -d -o jenkins -g jenkins "$JHOME/init.groovy.d"
retry curl --proto "=https" --tlsv1.2 -fsSL "$RAW/casc.yaml" -o "$JHOME/casc.yaml"
retry curl --proto "=https" --tlsv1.2 -fsSL "$RAW/plugins.txt" -o "$JHOME/plugins.txt"
retry curl --proto "=https" --tlsv1.2 -fsSL "$RAW/init-agent-secret.groovy" -o "$JHOME/init.groovy.d/10-write-agent-secret.groovy"

# 3. Install the plugins.
retry curl --proto "=https" --tlsv1.2 -fsSL -o /opt/jenkins-plugin-manager.jar \
  "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PIM_VERSION}/jenkins-plugin-manager-${PIM_VERSION}.jar"
retry java -jar /opt/jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war \
  --plugin-file "$JHOME/plugins.txt" --plugin-download-directory "$JHOME/plugins" --latest=false
chown -R jenkins:jenkins "$JHOME"

# 4. Write the secret files that casc.yaml reads (owner-only, no trailing newline).
umask 077
openssl rand -hex 24 | tr -d '\n' > "$SECRETS_DIR/admin-password"
retry aws ssm get-parameter --name /p3/app/db-password --with-decryption --query Parameter.Value --output text | tr -d '\n' > "$SECRETS_DIR/db-password"
retry aws ssm get-parameter --name /p3/app/rmq-password --with-decryption --query Parameter.Value --output text | tr -d '\n' > "$SECRETS_DIR/rmq-password"
ACCOUNT_ID=$(retry aws sts get-caller-identity --query Account --output text)
printf 'arn:aws:iam::%s:role/%s' "$ACCOUNT_ID" "$DEPLOY_ROLE_NAME" > "$SECRETS_DIR/deploy-role-arn"
chown jenkins:jenkins "$SECRETS_DIR"/*
aws ssm delete-parameter --name /p3/jenkins/agent-secret 2>/dev/null || true
retry aws ssm put-parameter --name /p3/jenkins/admin-password --type SecureString --overwrite \
  --value "file://$SECRETS_DIR/admin-password" > /dev/null

# 5. Tell Jenkins to skip the setup wizard and where the config file is, then start it.
install -d /etc/systemd/system/jenkins.service.d
cat > /etc/systemd/system/jenkins.service.d/override.conf << 'UNIT'
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"
Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc.yaml"
UNIT
systemctl daemon-reload
systemctl start jenkins

# 6. Safety check: wait for Jenkins, then confirm that anonymous access is denied.
ready=""
for _ in $(seq 1 60); do
  c=$(http_code http://localhost:8080/api/json)
  if [ "$c" != "000" ] && [ "$c" != "503" ]; then ready="$c"; break; fi
  sleep 5
done
[ -n "$ready" ] || fail_closed "Jenkins was not ready after 300 seconds"
case "$ready" in
  401|403) ;;
  *) fail_closed "anonymous /api/json returned $ready, expected 401 or 403" ;;
esac
c=$(printf 'user = "admin:%s"\n' "$(cat "$SECRETS_DIR/admin-password")" \
  | curl -s -o /dev/null -w '%{http_code}' --max-time 10 -K - http://localhost:8080/api/json || true)
[ "$c" = "200" ] || fail_closed "admin login returned $c, expected 200"

# 7. Hand the agent secret to the agent through Parameter Store, then delete the local copy.
for _ in $(seq 1 12); do
  [ -s "$SECRETS_DIR/agent-secret" ] && break
  sleep 5
done
[ -s "$SECRETS_DIR/agent-secret" ] || fail_closed "agent secret file was not written"
retry aws ssm put-parameter --name /p3/jenkins/agent-secret --type SecureString --overwrite \
  --value "file://$SECRETS_DIR/agent-secret" > /dev/null
rm -f "$SECRETS_DIR/agent-secret"
echo "p3: controller boot finished. Security check passed."


# 8. Check that Jenkins sees p3-agent as online. This only reports the result. It does not stop Jenkins.
agent_result=""
for _ in $(seq 1 120); do
  out=$(printf 'user = "admin:%s"\n' "$(cat "$SECRETS_DIR/admin-password")" \
    | curl -s -w '\n%{http_code}' --max-time 10 -K - http://localhost:8080/computer/p3-agent/api/json || true)
  code=${out##*$'\n'}
  json=${out%$'\n'*}
  if [ "$code" = "200" ]; then
    if printf '%s' "$json" | grep -Eq '"offline"[[:space:]]*:[[:space:]]*false'; then
      agent_result=online
      break
    fi
    agent_result=offline
  else
    agent_result="node API returned $code"
  fi
  sleep 5
done
if [ "$agent_result" = "online" ]; then
  echo "p3: PASS agent p3-agent is online"
else
  echo "p3: FAIL agent p3-agent not online after 600 seconds (last state: ${agent_result:-none})" >&2
  exit 1
fi

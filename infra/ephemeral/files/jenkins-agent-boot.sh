# Jenkins agent boot script. Terraform puts a shebang and this variable above it:
#   CONTROLLER_IP (private IPv4 address of the Jenkins controller)
# Never add `set -x` or echo a secret: this script's output goes to the cloud-init log.
set -euo pipefail
export HOME=/root
export DEBIAN_FRONTEND=noninteractive
export AWS_DEFAULT_REGION=us-east-1

CONTROLLER_URL="http://${CONTROLLER_IP}:8080"
AGENT_USER=jenkins-agent
AGENT_HOME=/home/jenkins-agent
SECRET_FILE="$AGENT_HOME/agent-secret"
JAVA21=/usr/lib/jvm/java-21-openjdk-amd64/bin/java
SSM_PLUGIN_VERSION=1.2.835.0

fail() {
  echo "p3: $1. Stopping." >&2
  exit 1
}
http_code() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$@" || true; }

case "$CONTROLLER_IP" in
  ""|*[!0-9.]*) fail "CONTROLLER_IP is not an IPv4 address" ;;
esac

# 1. Install packages. Java 21 runs the agent connection. Java 17 is for the Maven build.
apt-get update
apt-get install -y openjdk-21-jre-headless openjdk-17-jdk-headless maven git curl unzip python3-venv awscli

# 3. Install the Session Manager plugin, pinned to one version.
curl -fsSL -o /tmp/session-manager-plugin.deb \
  "https://s3.amazonaws.com/session-manager-downloads/plugin/${SSM_PLUGIN_VERSION}/ubuntu_64bit/session-manager-plugin.deb"
dpkg -i /tmp/session-manager-plugin.deb
rm -f /tmp/session-manager-plugin.deb

# 4. Create the agent user and folders.
id "$AGENT_USER" > /dev/null 2>&1 || useradd -m -d "$AGENT_HOME" -s /bin/bash "$AGENT_USER"
install -d -m 0755 -o "$AGENT_USER" -g "$AGENT_USER" "$AGENT_HOME/work" /opt/jenkins-agent

# 5. Wait for Jenkins. A 401 or 403 means it is up and anonymous access is denied.
#    The controller deletes any old agent secret before it starts Jenkins, so
#    waiting here also avoids reading a stale secret from an earlier session.
ready=""
for _ in $(seq 1 120); do
  c=$(http_code "$CONTROLLER_URL/api/json")
  case "$c" in
    401|403) ready=1; break ;;
  esac
  sleep 5
done
[ -n "$ready" ] || fail "controller did not answer with 401 or 403 after 600 seconds"

# 6. Download the agent program from the controller.
c=$(curl -s -o /opt/jenkins-agent/agent.jar -w '%{http_code}' --max-time 60 "$CONTROLLER_URL/jnlpJars/agent.jar" || true)
[ "$c" = "200" ] || fail "agent.jar download returned $c, expected 200"
chown "$AGENT_USER:$AGENT_USER" /opt/jenkins-agent/agent.jar

# 7. Read the agent secret from Parameter Store into an owner-only file (no trailing newline).
umask 077
got=""
for _ in $(seq 1 60); do
  if aws ssm get-parameter --name /p3/jenkins/agent-secret --with-decryption \
      --query Parameter.Value --output text 2> /dev/null | tr -d '\n' > "$SECRET_FILE" \
      && [ -s "$SECRET_FILE" ]; then
    got=1
    break
  fi
  sleep 10
done
[ -n "$got" ] || fail "agent secret was not available after 600 seconds"
chown "$AGENT_USER:$AGENT_USER" "$SECRET_FILE"
chmod 0600 "$SECRET_FILE"

# 8. Run the agent as a service. The secret is passed as @file, not on the command line.
cat > /etc/systemd/system/jenkins-agent.service << UNIT
[Unit]
Description=Jenkins agent p3-agent
After=network-online.target
Wants=network-online.target

[Service]
User=$AGENT_USER
WorkingDirectory=$AGENT_HOME
ExecStart=$JAVA21 -jar /opt/jenkins-agent/agent.jar -url $CONTROLLER_URL/ -name p3-agent -secret @$SECRET_FILE -webSocket -workDir $AGENT_HOME/work
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now jenkins-agent

# 9. Basic check: the service is still running after 15 seconds.
sleep 15
systemctl is-active --quiet jenkins-agent || fail "jenkins-agent service is not running"
echo "p3: agent boot finished. Check that p3-agent shows as online in Jenkins."
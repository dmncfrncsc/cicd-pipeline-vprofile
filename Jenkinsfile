// Manual build, test, and deploy of VProfile on the Jenkins lab agent.
// Same flow as .github/workflows/deploy.yml. No triggers, and never archive the WAR.
pipeline {
  agent { label 'p3-build' }

  options {
    skipDefaultCheckout(true)
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }

  parameters {
    string(name: 'INSTANCE_ID', defaultValue: '', description: 'EC2 instance ID of the app instance (i-...)')
    booleanParam(name: 'FORCE_FAILURE', defaultValue: false, description: 'Force the deploy to fail, to test rollback')
  }

  environment {
    JAVA_HOME          = '/usr/lib/jvm/java-17-openjdk-amd64'
    WAR_PATH           = 'build-work/target/vprofile-v2.war'
    WAR_BUCKET         = 'p3-vprofile-war-k7m3q9'
    TRANSFER_BUCKET    = 'p3-vprofile-ansible-transfer-k7m3q9'
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Check input') {
      steps {
        sh '''#!/bin/bash
set -euo pipefail
[[ "$INSTANCE_ID" =~ ^i-[0-9a-f]{8,17}$ ]] || { echo "Bad instance ID"; exit 1; }
'''
      }
    }

    stage('Checkout') {
      steps {
        // Checks out this repository and the pinned vprofile-src submodule.
        checkout([
          $class: 'GitSCM',
          branches: scm.branches,
          userRemoteConfigs: scm.userRemoteConfigs,
          extensions: [[
            $class: 'SubmoduleOption',
            disableSubmodules: false,
            recursiveSubmodules: false,
            trackingSubmodules: false,
            parentCredentials: false,
            reference: '',
            timeout: 10
          ]]
        ])
      }
    }

    stage('Build and test') {
      steps {
        sh '''#!/bin/bash
set -euo pipefail
export PATH="$JAVA_HOME/bin:$PATH"
java -version 2>&1 | sed -n 1p
bash scripts/build.sh
'''
      }
    }

    stage('Deploy over SSM') {
      steps {
        withCredentials([
          string(credentialsId: 'deploy-role-arn', variable: 'DEPLOY_ROLE_ARN'),
          string(credentialsId: 'db-password', variable: 'DB_PASSWORD'),
          string(credentialsId: 'rmq-password', variable: 'RMQ_PASSWORD')
        ]) {
          // The shebang line stops Jenkins from adding "set -x", so no command is echoed.
          sh '''#!/bin/bash
set -euo pipefail
set +x
umask 077
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Assume the Jenkins deploy role. The session name must start with p3-deploy-jenkins-.
CREDS=$(aws sts assume-role \
  --role-arn "$DEPLOY_ROLE_ARN" \
  --role-session-name "p3-deploy-jenkins-${BUILD_NUMBER}" \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text)
read -r AK SK ST <<< "$CREDS"
export AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" AWS_SESSION_TOKEN="$ST"
unset CREDS AK SK ST

# Confirm the identity before anything is uploaded or deployed.
ARN=$(aws sts get-caller-identity --query Arn --output text)
case "$ARN" in
  *":assumed-role/p3-vprofile-jenkins-deploy/p3-deploy-jenkins-"*) echo "Identity check passed" ;;
  *) echo "Unexpected identity"; exit 1 ;;
esac

# Upload the WAR to the private bucket.
aws s3 cp "$WAR_PATH" "s3://$WAR_BUCKET/vprofile-v2.war"

# Write the deploy variables as JSON (owner-only file, removed on exit).
python3 -c 'import json,os; print(json.dumps({"db_password": os.environ["DB_PASSWORD"], "rmq_password": os.environ["RMQ_PASSWORD"], "war_path": os.path.join(os.environ["WORKSPACE"], os.environ["WAR_PATH"])}))' > "$TMP/vars.json"

# Install the pinned Ansible tools, same versions as the GitHub workflow.
python3 -m venv "$TMP/venv"
"$TMP/venv/bin/pip" install --quiet --no-cache-dir ansible-core==2.21.4 boto3
"$TMP/venv/bin/ansible-galaxy" collection install amazon.aws:==11.4.0 ansible.mysql:==5.2.0 community.rabbitmq:==1.7.0
export PATH="$TMP/venv/bin:$PATH"

ansible-playbook ansible/deploy.yml \
  -i "$INSTANCE_ID," \
  -e ansible_connection=amazon.aws.aws_ssm \
  -e ansible_aws_ssm_bucket_name="$TRANSFER_BUCKET" \
  -e ansible_aws_ssm_region=us-east-1 \
  -e force_failure="$FORCE_FAILURE" \
  -e @"$TMP/vars.json"
'''
        }
      }
    }
  }
}
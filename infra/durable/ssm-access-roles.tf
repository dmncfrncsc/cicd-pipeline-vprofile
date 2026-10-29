# SSM access to the Jenkins controller UI (design approved 2026-10-29; applied to the durable stack per author report).
# Reaching Jenkins on port 8080 needs no inbound security group rule.

locals {
  ssm_access_account = data.aws_caller_identity.current.account_id
  ssm_access_region  = "us-east-1"
  p3_cli_user_arn    = "arn:aws:iam::${local.ssm_access_account}:user/p3-cli"
}

# Port forwarding fixed to 8080. The caller cannot choose another remote port.
resource "aws_ssm_document" "jenkins_port_8080" {
  name            = "p3-jenkins-port-8080"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Forward a local port to Jenkins on port 8080"
    sessionType   = "Port"
    parameters = {
      localPortNumber = {
        type        = "String"
        description = "Local port on your computer"
        default     = "8080"
      }
    }
    properties = {
      portNumber      = "8080"
      localPortNumber = "{{ localPortNumber }}"
      type            = "LocalPortForwarding"
    }
  })
}

# --- Operator role: open the Jenkins page only ---------------------------------

resource "aws_iam_role" "jenkins_operator" {
  name                 = "p3-jenkins-operator"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = local.p3_cli_user_arn }
      Action    = "sts:AssumeRole"
      Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_operator" {
  name = "jenkins-operator-permissions"
  role = aws_iam_role.jenkins_operator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StartSessionOnlyWithPinnedDocument"
        Effect   = "Allow"
        Action   = "ssm:StartSession"
        Resource = aws_ssm_document.jenkins_port_8080.arn
      },
      {
        Sid      = "StartSessionOnlyOnControllerTag"
        Effect   = "Allow"
        Action   = "ssm:StartSession"
        Resource = "arn:aws:ec2:${local.ssm_access_region}:${local.ssm_access_account}:instance/*"
        Condition = {
          StringEquals = { "ssm:resourceTag/Role" = "jenkins-controller" }
        }
      },
      {
        Sid      = "EndOwnSessions"
        Effect   = "Allow"
        Action   = ["ssm:TerminateSession", "ssm:ResumeSession"]
        Resource = "arn:aws:ssm:*:*:session/$${aws:userid}-*"
      }
    ]
  })
}

# --- Secret-reader role: read the Jenkins admin password only -------------------

resource "aws_iam_role" "jenkins_secret_reader" {
  name                 = "p3-jenkins-secret-reader"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = local.p3_cli_user_arn }
      Action    = "sts:AssumeRole"
      Condition = { Bool = { "aws:MultiFactorAuthPresent" = "true" } }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_secret_reader" {
  name = "jenkins-secret-reader-permissions"
  role = aws_iam_role.jenkins_secret_reader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadJenkinsAdminPasswordOnly"
      Effect   = "Allow"
      Action   = "ssm:GetParameter"
      Resource = "arn:aws:ssm:${local.ssm_access_region}:${local.ssm_access_account}:parameter/p3/jenkins/admin-password"
    }]
  })
}
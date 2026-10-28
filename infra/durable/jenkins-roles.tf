# Roles for the Jenkins lab hosts and for the Jenkins deploy path.
# Nothing here changes the existing GitHub Actions deploy role or the app instance role.
# local.account_id and local.ssm_agent_actions come from deploy-role.tf and instance-role.tf.
#
# Prerequisite outside Terraform: the policy named in
# local.jenkins_instance_boundary_arn must already exist, like the other two
# boundary policies. It is not created here.

locals {
  jenkins_instance_boundary_arn = "arn:aws:iam::${local.account_id}:policy/p3-vprofile-jenkins-instance-boundary"
  ssm_parameter_arn_prefix      = "arn:aws:ssm:us-east-1:${local.account_id}:parameter"
}

# --- Controller --------------------------------------------------------------

resource "aws_iam_role" "jenkins_controller" {
  name                 = "p3-vprofile-jenkins-controller-role"
  permissions_boundary = local.jenkins_instance_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowEc2ServiceToAssume"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_controller" {
  name = "jenkins-controller-permissions"
  role = aws_iam_role.jenkins_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SsmAgentCore"
        Effect   = "Allow"
        Action   = local.ssm_agent_actions
        Resource = "*"
      },
      {
        Sid    = "ReadTwoAppSecrets"
        Effect = "Allow"
        Action = "ssm:GetParameter"
        Resource = [
          "${local.ssm_parameter_arn_prefix}/p3/app/db-password",
          "${local.ssm_parameter_arn_prefix}/p3/app/rmq-password",
        ]
      },
      {
        Sid    = "WriteJenkinsParameters"
        Effect = "Allow"
        Action = "ssm:PutParameter"
        Resource = [
          "${local.ssm_parameter_arn_prefix}/p3/jenkins/admin-password",
          "${local.ssm_parameter_arn_prefix}/p3/jenkins/agent-secret",
        ]
      },
      {
        Sid      = "DeleteOldAgentSecret"
        Effect   = "Allow"
        Action   = "ssm:DeleteParameter"
        Resource = "${local.ssm_parameter_arn_prefix}/p3/jenkins/agent-secret"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_controller" {
  name = "p3-vprofile-jenkins-controller-profile"
  role = aws_iam_role.jenkins_controller.name
}

# --- Agent -------------------------------------------------------------------

resource "aws_iam_role" "jenkins_agent" {
  name                 = "p3-vprofile-jenkins-agent-role"
  permissions_boundary = local.jenkins_instance_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowEc2ServiceToAssume"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_agent" {
  name = "jenkins-agent-permissions"
  role = aws_iam_role.jenkins_agent.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SsmAgentCore"
        Effect   = "Allow"
        Action   = local.ssm_agent_actions
        Resource = "*"
      },
      {
        Sid      = "ReadAgentSecret"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "${local.ssm_parameter_arn_prefix}/p3/jenkins/agent-secret"
      },
      {
        Sid      = "AssumeJenkinsDeployRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.jenkins_deploy.arn
      },
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "p3-vprofile-jenkins-agent-profile"
  role = aws_iam_role.jenkins_agent.name
}

# --- Jenkins deploy role -----------------------------------------------------
# Same permissions as the GitHub Actions deploy role, but only the Jenkins agent
# role can assume it, and only with a session name that starts with
# p3-deploy-jenkins-. The Jenkinsfile must use that session name.
# It reuses the existing deploy boundary because the permissions are the same.

resource "aws_iam_role" "jenkins_deploy" {
  name                 = "p3-vprofile-jenkins-deploy"
  permissions_boundary = local.deploy_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowJenkinsAgentRoleOnly"
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.jenkins_agent.arn }
      Action    = "sts:AssumeRole"
      Condition = { StringLike = { "sts:RoleSessionName" = "p3-deploy-jenkins-*" } }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_deploy" {
  name = "deploy-permissions"
  role = aws_iam_role.jenkins_deploy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WarBucketObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
        Resource = "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
      },
      {
        Sid      = "WarBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:ListBucketVersions"]
        Resource = "arn:aws:s3:::p3-vprofile-war-k7m3q9"
      },
      {
        Sid      = "TransferBucketObjects"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/i-*/*"
      },
      {
        Sid      = "TransferBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
      },
      {
        Sid       = "StartSessionOnTaggedInstances"
        Effect    = "Allow"
        Action    = "ssm:StartSession"
        Resource  = "arn:aws:ec2:us-east-1:${local.account_id}:instance/*"
        Condition = { StringEquals = { "ssm:resourceTag/Project" = "p3-vprofile" } }
      },
      {
        Sid      = "StartSessionDocumentUnverified"
        Effect   = "Allow"
        Action   = "ssm:StartSession"
        Resource = "arn:aws:ssm:us-east-1:${local.account_id}:document/SSM-SessionManagerRunShell"
      },
      {
        Sid    = "OwnSessionsOnly"
        Effect = "Allow"
        Action = [
          "ssmmessages:OpenDataChannel",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
        ]
        Resource = "arn:aws:ssm:us-east-1:${local.account_id}:session/p3-deploy-jenkins-*"
      },
      {
        Sid    = "SessionReadOnly"
        Effect = "Allow"
        Action = [
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceProperties",
          "ec2:DescribeInstances",
        ]
        Resource  = "*"
        Condition = { StringEquals = { "aws:RequestedRegion" = "us-east-1" } }
      },
    ]
  })
}

# Pass these names to the ephemeral root (jenkins_*_name variables).
output "jenkins_controller_profile_name" {
  value = aws_iam_instance_profile.jenkins_controller.name
}

output "jenkins_agent_profile_name" {
  value = aws_iam_instance_profile.jenkins_agent.name
}

output "jenkins_deploy_role_name" {
  value = aws_iam_role.jenkins_deploy.name
}

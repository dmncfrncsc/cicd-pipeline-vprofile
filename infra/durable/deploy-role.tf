locals {
  account_id          = data.aws_caller_identity.current.account_id
  deploy_boundary_arn = "arn:aws:iam::${local.account_id}:policy/p3-vprofile-deploy-boundary"
}

# Tells AWS to trust login tokens signed by GitHub Actions.
# No thumbprint_list: AWS verifies GitHub's certificate itself.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# The role a GitHub Actions deploy job takes on. Trust is one-shot:
# p3-terraform is denied iam:UpdateAssumeRolePolicy and iam:DeleteRole on it.
resource "aws_iam_role" "deploy" {
  name                 = "p3-vprofile-deploy"
  permissions_boundary = local.deploy_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowGitHubExactProductionSubject"
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:dmncfrncsc@104504982/cicd-pipeline-vprofile@1399501719:environment:production"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "deploy" {
  name = "deploy-permissions"
  role = aws_iam_role.deploy.id

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
        # $${ is how Terraform writes a literal ${ that IAM, not Terraform, fills in.
        Resource = "arn:aws:ssm:us-east-1:${local.account_id}:session/$${aws:userid}-*"
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

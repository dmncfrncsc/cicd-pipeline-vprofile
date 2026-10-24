data "aws_caller_identity" "current" {}

locals {
  instance_boundary_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/p3-vprofile-instance-boundary"

  ssm_agent_actions = [
    "ssm:DescribeAssociation",
    "ssm:GetDeployablePatchSnapshotForInstance",
    "ssm:GetDocument",
    "ssm:DescribeDocument",
    "ssm:GetManifest",
    "ssm:ListAssociations",
    "ssm:ListInstanceAssociations",
    "ssm:PutInventory",
    "ssm:PutComplianceItems",
    "ssm:PutConfigurePackageResult",
    "ssm:UpdateAssociationStatus",
    "ssm:UpdateInstanceAssociationStatus",
    "ssm:UpdateInstanceInformation",
    "ssmmessages:CreateControlChannel",
    "ssmmessages:CreateDataChannel",
    "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel",
    "ec2messages:AcknowledgeMessage",
    "ec2messages:DeleteMessage",
    "ec2messages:FailMessage",
    "ec2messages:GetEndpoint",
    "ec2messages:GetMessages",
    "ec2messages:SendReply",
  ]
}

resource "aws_iam_role" "instance" {
  name                 = "p3-vprofile-instance-role"
  permissions_boundary = local.instance_boundary_arn

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

resource "aws_iam_role_policy" "instance_ssm_agent" {
  name = "ssm-agent-core"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "SsmAgentCore"
      Effect   = "Allow"
      Action   = local.ssm_agent_actions
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "instance" {
  name = "p3-vprofile-instance-profile"
  role = aws_iam_role.instance.name
}

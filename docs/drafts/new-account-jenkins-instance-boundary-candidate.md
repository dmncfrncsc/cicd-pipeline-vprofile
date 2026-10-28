# Jenkins instance boundary: review-only candidate

Status: proposal, not created in IAM, not applied. Created outside Terraform, because `infra/durable/jenkins-roles.tf` expects the policy `p3-vprofile-jenkins-instance-boundary` to already exist. It caps the Jenkins controller and agent roles. Each statement mirrors an inline policy statement in `jenkins-roles.tf` and grants nothing wider. If either inline policy gains a permission, update this boundary too. Untested against AWS. `<ACCOUNT_ID>` is a placeholder.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SsmAgentCore",
      "Effect": "Allow",
      "Action": [
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
        "ec2messages:SendReply"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ReadTwoAppSecrets",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": [
        "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/app/db-password",
        "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/app/rmq-password"
      ]
    },
    {
      "Sid": "ReadAgentSecret",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/jenkins/agent-secret"
    },
    {
      "Sid": "WriteJenkinsParameters",
      "Effect": "Allow",
      "Action": "ssm:PutParameter",
      "Resource": [
        "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/jenkins/admin-password",
        "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/jenkins/agent-secret"
      ]
    },
    {
      "Sid": "DeleteOldAgentSecret",
      "Effect": "Allow",
      "Action": "ssm:DeleteParameter",
      "Resource": "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:parameter/p3/jenkins/agent-secret"
    },
    {
      "Sid": "AssumeJenkinsDeployRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-deploy"
    }
  ]
}
```
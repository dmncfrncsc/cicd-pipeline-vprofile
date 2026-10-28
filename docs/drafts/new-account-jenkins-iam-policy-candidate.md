# Jenkins additions to `p3-terraform` — review-only candidate

**Status:** Proposed in the supplied conversation for review only. This is not the saved AWS policy and has not been validated, approved for attachment, or applied. A permissions boundary caps what a role can do but does not grant permissions. `<ACCOUNT_ID>` is a placeholder and must remain replaced in any public copy.

The author approved continuing the policy review and, on 2026-10-28, approved a separate customer-managed `p3-terraform-jenkins` policy as the approach for this review-only draft. That approval covers drafting only. Creating the policy in IAM, attaching it to `p3-terraform`, and running Terraform each still need separate approval. The existing networking draft allows security group egress rules only, and `jenkins.tf` creates one ingress rule (TCP 8080 from the agent to the controller), so two ingress statements were added at the end of the policy. They are untested against AWS, and the policy actually attached to `p3-terraform` (Version 5) was not compared with the drafts.

This JSON is preserved from the conversation's proposal. Do not create or attach it until its actions, resources, conditions, policy-size limits, and approval are reviewed.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CreateJenkinsInstanceRoles",
      "Effect": "Allow",
      "Action": "iam:CreateRole",
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-controller-role",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-agent-role"
      ],
      "Condition": { "StringEquals": { "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-jenkins-instance-boundary" } }
    },
    {
      "Sid": "CreateJenkinsDeployRole",
      "Effect": "Allow",
      "Action": "iam:CreateRole",
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-deploy",
      "Condition": { "StringEquals": { "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary" } }
    },
    {
      "Sid": "ManageJenkinsRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole", "iam:GetRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
        "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:ListInstanceProfilesForRole"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-controller-role",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-agent-role",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-deploy"
      ]
    },
    {
      "Sid": "ChangeOrDeleteJenkinsInstanceRoles",
      "Effect": "Allow",
      "Action": ["iam:UpdateAssumeRolePolicy", "iam:DeleteRole"],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-controller-role",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-agent-role"
      ]
    },
    {
      "Sid": "DenyJenkinsDeployRoleTrustChanges",
      "Effect": "Deny",
      "Action": ["iam:UpdateAssumeRolePolicy", "iam:DeleteRole"],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-deploy"
    },
    {
      "Sid": "PassJenkinsInstanceRolesToEc2",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-controller-role",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-jenkins-agent-role"
      ],
      "Condition": { "StringEquals": { "iam:PassedToService": "ec2.amazonaws.com" } }
    },
    {
      "Sid": "ManageJenkinsInstanceProfiles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile", "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile", "iam:DeleteInstanceProfile"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:instance-profile/p3-vprofile-jenkins-controller-profile",
        "arn:aws:iam::<ACCOUNT_ID>:instance-profile/p3-vprofile-jenkins-agent-profile"
      ]
    },
    {
      "Sid": "BucketPublicAccessBlock",
      "Effect": "Allow",
      "Action": ["s3:PutBucketPublicAccessBlock", "s3:GetBucketPublicAccessBlock"],
      "Resource": [
        "arn:aws:s3:::p3-vprofile-war-k7m3q9",
        "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
      ]
    },
    {
      "Sid": "LaunchJenkinsInstances",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": { "StringEquals": {
        "aws:RequestTag/Project": "p3-vprofile-jenkins",
        "aws:RequestTag/Role": ["jenkins-controller", "jenkins-agent"]
      } }
    },
    {
      "Sid": "LaunchJenkinsVolumes",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*",
      "Condition": { "StringEquals": { "aws:RequestTag/Project": "p3-vprofile-jenkins" } }
    },
    {
      "Sid": "TagJenkinsResourcesAtLaunch",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*"
      ],
      "Condition": { "StringEquals": {
        "ec2:CreateAction": "RunInstances",
        "aws:RequestTag/Project": "p3-vprofile-jenkins"
      } }
    },
    {
      "Sid": "ManageJenkinsInstances",
      "Effect": "Allow",
      "Action": ["ec2:TerminateInstances", "ec2:StopInstances", "ec2:ModifyInstanceAttribute"],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": { "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile-jenkins" } }
    },
    {
      "Sid": "EphemeralSecurityGroupIngressJenkins",
      "Effect": "Allow",
      "Action": ["ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress"],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*",
      "Condition": { "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" } }
    },
    {
      "Sid": "EphemeralSecurityGroupRuleIngressCreate",
      "Effect": "Allow",
      "Action": "ec2:AuthorizeSecurityGroupIngress",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group-rule/*",
      "Condition": { "StringEquals": { "aws:RequestTag/Project": "p3-vprofile" } }
    }
    
  ]
}
```

**Ingress statements (proposed, not applied):** the two ingress statements use `Project = p3-vprofile`, the provider default tag set in `infra/ephemeral/versions.tf`, because the Jenkins security groups and rules inherit it. The instance statements above use `p3-vprofile-jenkins` because `jenkins.tf` overrides the tag on the two instances only. `RevokeSecurityGroupIngress` is included so Jenkins-only teardown can remove the agent-to-controller rule. None of this is tested against AWS. Whether the provider sends the rule's tag in the authorize call or in a separate `CreateTags` call is unverified.


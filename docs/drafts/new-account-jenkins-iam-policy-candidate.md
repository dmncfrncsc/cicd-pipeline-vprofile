# Jenkins additions to `p3-terraform` — review-only candidate

**Status:** Proposed in the supplied conversation for review only. This is not the saved AWS policy and has not been validated, approved for attachment, or applied. A permissions boundary caps what a role can do but does not grant permissions. `<ACCOUNT_ID>` is a placeholder and must remain replaced in any public copy.

The author approved continuing the policy review. The assistant proposed a separate customer-managed `p3-terraform-jenkins` policy instead of the previously discussed edit to existing policies, and said this change of approach needs approval. No approval to create or attach this separate policy appears later in the conversation. The candidate also assumes existing networking permissions cover Jenkins security groups; check whether `ec2:AuthorizeSecurityGroupIngress` is allowed before treating it as complete.

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
    }
  ]
}
```

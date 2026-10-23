# New-account IAM policy draft package

**Status: review-only drafts, not applied. Updated 2026-10-23.** This package preserves the 15-statement durable-layer reconstruction, a separate 14-statement option-B reconstruction derived from it, two earlier full boundary drafts marked superseded, and the current redrafted boundaries in the final section. The original reported 14-statement policy was not recovered. These texts are documentation for continued review, not deployable policy files or approval to create or change AWS resources.

Replace `<ACCOUNT_ID>` only in a private working copy if a later, separately approved implementation requires it. Never put the real account ID in this public repository.

## Decisions and limits

- The author first approved Terraform creating and managing the two named boundary policies as a planning decision, then chose option B on 2026-10-22, superseding it: the boundaries are planned to be created outside `p3-terraform` in a separately approved root session. The preserved 15-statement reconstruction below retains the superseded `ManageTwoBoundaryPolicies` statement; the separate option-B revision at the end removes only that statement. Both remain reconstructions, and the 14-statement revision is not the unrecovered original JSON. This does not approve applying these drafts or starting a root session.
- The preserved `ManageTwoNamedRoles` statement includes `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` on the project roles. Option B removes Terraform's ability to edit boundary-policy text, but not its ability to change the roles' permission policies or trust. The effective impact is unverified, depends on the undrafted role/trust policies and boundary controls, and has not been explicitly accepted; see the [new-account design decision](../decisions/new-account-deployment-design.md).
- The durable policy includes `s3:PutBucketPolicy` on the WAR and Ansible-transfer buckets. The author’s explicit acceptance of that exposure is not recorded; it remains undecided. The separate temporary acceptance for the bootstrap state-bucket policy does not apply to these two buckets.
- The 15-statement durable policy is a reconstruction from an earlier 11-statement draft and later summarized additions. It is not the unrecovered original 14-statement text. The two earlier full boundary drafts are retained below as superseded; the redrafted boundary JSON in the final section is the current review-only planning version dated 2026-10-23.
- The superseded earlier deploy boundary used `SsmDocumentsUnverified` for broad SSM document resources and `SsmOwnSessionsOnly` with a `${aws:userid}` session ARN pattern. The redrafted deploy boundary names `SSM-SessionManagerRunShell`, but its existence and use by the plugin remain unverified; the exact match between the session ARN pattern and the workflow’s chosen role-session name also remains unverified. The redrafted instance boundary excludes `ssm:GetParameter` and `ssm:GetParameters`.
- Encryption mode, the `p3-terraform` trust policy and MFA condition, the ephemeral-layer IAM policy and state key, and the compatibility/scope of `iam:PassRole` for EC2 launch remain open. See the [new-account design decision](../decisions/new-account-deployment-design.md).
- The reported character counts and AWS quota calculations have not been independently verified. No policy in this package is recorded as applied.

## Durable-layer policy reconstruction

Reported as 15 statements; `<ACCOUNT_ID>` remains a placeholder. This preserved reconstruction still contains the superseded `ManageTwoBoundaryPolicies` statement, which must be removed before any application.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StateBucketTagFix",
      "Effect": "Allow",
      "Action": [
        "s3:UntagResource"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2"
    },
    {
      "Sid": "ManageDurableBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:ListTagsForResource",
        "s3:GetBucketLocation",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketWebsite",
        "s3:GetBucketLogging",
        "s3:GetBucketRequestPayment",
        "s3:GetAccelerateConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketOwnershipControls",
        "s3:PutBucketOwnershipControls",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging",
        "s3:TagResource",
        "s3:UntagResource"
      ],
      "Resource": [
        "arn:aws:s3:::p3-vprofile-war-k7m3q9",
        "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
      ]
    },
    {
      "Sid": "DurableStateObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/durable/terraform.tfstate"
    },
    {
      "Sid": "DurableStateLockObject",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/durable/terraform.tfstate.tflock"
    },
    {
      "Sid": "ManageGithubOidcProvider",
      "Effect": "Allow",
      "Action": [
        "iam:CreateOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:AddClientIDToOpenIDConnectProvider",
        "iam:RemoveClientIDFromOpenIDConnectProvider",
        "iam:TagOpenIDConnectProvider",
        "iam:UntagOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
    },
    {
      "Sid": "ListOidcProvidersReadOnly",
      "Effect": "Allow",
      "Action": [
        "iam:ListOpenIDConnectProviders"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ManageTwoNamedRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:PutRolePolicy",
        "iam:GetRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
      ]
    },
    {
      "Sid": "CreateDeployRoleOnlyWithDeployBoundary",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:PutRolePermissionsBoundary"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary"
        }
      }
    },
    {
      "Sid": "CreateInstanceRoleOnlyWithInstanceBoundary",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:PutRolePermissionsBoundary"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-instance-boundary"
        }
      }
    },
    {
      "Sid": "PassOnlyTheInstanceRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
    },
    {
      "Sid": "ManageInstanceProfile",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:TagInstanceProfile",
        "iam:UntagInstanceProfile"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:instance-profile/p3-vprofile-instance-profile"
    },
    {
      "Sid": "ReadBoundaryPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary",
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-instance-boundary"
      ]
    },
    {
      "Sid": "ManageTwoBoundaryPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:SetDefaultPolicyVersion"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary",
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-instance-boundary"
      ]
    },
    {
      "Sid": "DenySelfAndCliChanges",
      "Effect": "Deny",
      "Action": [
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:UpdateAssumeRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:DeleteRolePermissionsBoundary",
        "iam:DeleteRole",
        "iam:PutUserPolicy",
        "iam:DeleteUserPolicy",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:DeleteUser"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-terraform",
        "arn:aws:iam::<ACCOUNT_ID>:user/p3-cli"
      ]
    },
    {
      "Sid": "DenyRemovingBoundaryFromProjectRoles",
      "Effect": "Deny",
      "Action": [
        "iam:DeleteRolePermissionsBoundary"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
      ]
    }
  ]
}
```

## Deploy-role permissions boundary draft (superseded 2026-10-23; see the redrafted boundaries at the end of this file)

Latest earlier full draft present in the author-supplied material; eight statements. `<ACCOUNT_ID>` remains a placeholder.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WarBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
    },
    {
      "Sid": "WarBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9"
    },
    {
      "Sid": "TransferBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/*"
    },
    {
      "Sid": "TransferBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
    },
    {
      "Sid": "SsmOnTaggedInstancesOnly",
      "Effect": "Allow",
      "Action": ["ssm:SendCommand", "ssm:StartSession"],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": {
        "StringEquals": {
          "ssm:resourceTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "SsmDocumentsUnverified",
      "Effect": "Allow",
      "Action": ["ssm:SendCommand", "ssm:StartSession"],
      "Resource": [
        "arn:aws:ssm:us-east-1::document/*",
        "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:document/*"
      ]
    },
    {
      "Sid": "SsmOwnSessionsOnly",
      "Effect": "Allow",
      "Action": [
        "ssmmessages:OpenDataChannel",
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": "arn:aws:ssm:*:*:session/${aws:userid}-*"
    },
    {
      "Sid": "SsmReadResults",
      "Effect": "Allow",
      "Action": [
        "ssm:GetCommandInvocation",
        "ssm:ListCommandInvocations",
        "ssm:DescribeInstanceInformation",
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

## Instance-role permissions boundary draft (superseded 2026-10-23; see the redrafted boundaries at the end of this file)

Latest earlier full draft present in the author-supplied material; five statements. `<ACCOUNT_ID>` remains a placeholder.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SsmCoreCopiedFromAwsManagedPolicy",
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
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
      "Sid": "WarBucketReadOnly",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
    },
    {
      "Sid": "WarBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9"
    },
    {
      "Sid": "TransferBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/*"
    },
    {
      "Sid": "TransferBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
    }
  ]
}
```

## Option B revision: durable-layer policy (14 statements, review-only reconstruction)

**Status: review-only, not applied. Added 2026-10-22.** This copy is made from the preserved 15-statement reconstruction above by removing only `ManageTwoBoundaryPolicies`, following the author’s option B boundary-ownership decision. It remains a reconstruction, not the unrecovered original 14-statement policy, and is not a deployable policy file. It does not authorize a root session or any AWS change. `<ACCOUNT_ID>` remains a placeholder.

Review notes:

- `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` remain in `ManageTwoNamedRoles` for review. Their associated risk is undecided and not accepted. An MFA challenge used to assume a role controls credential issuance; by itself, it does not restrict actions in an issued session. Terraform plan review does not prevent direct API calls. Since `iam:DeleteRole` and conditional `iam:CreateRole` also remain, removing only `iam:UpdateAssumeRolePolicy` would not prevent changing trust by recreating a role. Preventing Terraform from creating, deleting, or changing trust would require those role-lifecycle operations to happen outside `p3-terraform`. The `p3-terraform` trust/MFA condition and effective permissions remain unverified; this is policy-draft analysis, not a live permission check or AWS-source verification.
- The superseded earlier deploy boundary’s `SsmDocumentsUnverified` statement allowed broad SSM document resources. The 2026-10-23 redraft narrows the document ARN to `SSM-SessionManagerRunShell`; whether that document exists in the new account and is the one used by the plugin remains unresolved.
- Static review of this exact JSON found no remaining `Allow` for `iam:CreatePolicy`, `iam:DeletePolicy`, `iam:CreatePolicyVersion`, `iam:DeletePolicyVersion`, or `iam:SetDefaultPolicyVersion`, and no explicit `Deny` for those actions. This means the draft itself relies on the absence of an `Allow`; it does not establish effective permissions. Other policies attached to `p3-terraform` could add those actions, and the reported attached-policy set was not independently verified. `iam:DeleteRolePermissionsBoundary` is explicitly denied for both project roles; role creation and boundary attachment are conditioned on the matching boundary ARN; `iam:AttachRolePolicy` and `iam:DetachRolePolicy` are not allowed by this draft. An explicit deny for boundary-policy edits remains an undecided alternative and is not included.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "StateBucketTagFix",
      "Effect": "Allow",
      "Action": [
        "s3:UntagResource"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2"
    },
    {
      "Sid": "ManageDurableBuckets",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:ListBucket",
        "s3:ListTagsForResource",
        "s3:GetBucketLocation",
        "s3:GetBucketAcl",
        "s3:GetBucketCORS",
        "s3:GetBucketWebsite",
        "s3:GetBucketLogging",
        "s3:GetBucketRequestPayment",
        "s3:GetAccelerateConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetBucketOwnershipControls",
        "s3:PutBucketOwnershipControls",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetBucketPublicAccessBlock",
        "s3:GetLifecycleConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging",
        "s3:TagResource",
        "s3:UntagResource"
      ],
      "Resource": [
        "arn:aws:s3:::p3-vprofile-war-k7m3q9",
        "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
      ]
    },
    {
      "Sid": "DurableStateObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/durable/terraform.tfstate"
    },
    {
      "Sid": "DurableStateLockObject",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/durable/terraform.tfstate.tflock"
    },
    {
      "Sid": "ManageGithubOidcProvider",
      "Effect": "Allow",
      "Action": [
        "iam:CreateOpenIDConnectProvider",
        "iam:GetOpenIDConnectProvider",
        "iam:UpdateOpenIDConnectProviderThumbprint",
        "iam:AddClientIDToOpenIDConnectProvider",
        "iam:RemoveClientIDFromOpenIDConnectProvider",
        "iam:TagOpenIDConnectProvider",
        "iam:UntagOpenIDConnectProvider",
        "iam:DeleteOpenIDConnectProvider"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
    },
    {
      "Sid": "ListOidcProvidersReadOnly",
      "Effect": "Allow",
      "Action": [
        "iam:ListOpenIDConnectProviders"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ManageTwoNamedRoles",
      "Effect": "Allow",
      "Action": [
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:PutRolePolicy",
        "iam:GetRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
      ]
    },
    {
      "Sid": "CreateDeployRoleOnlyWithDeployBoundary",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:PutRolePermissionsBoundary"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary"
        }
      }
    },
    {
      "Sid": "CreateInstanceRoleOnlyWithInstanceBoundary",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:PutRolePermissionsBoundary"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role",
      "Condition": {
        "StringEquals": {
          "iam:PermissionsBoundary": "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-instance-boundary"
        }
      }
    },
    {
      "Sid": "PassOnlyTheInstanceRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
    },
    {
      "Sid": "ManageInstanceProfile",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:TagInstanceProfile",
        "iam:UntagInstanceProfile"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:instance-profile/p3-vprofile-instance-profile"
    },
    {
      "Sid": "ReadBoundaryPolicies",
      "Effect": "Allow",
      "Action": [
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:ListPolicyVersions"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-deploy-boundary",
        "arn:aws:iam::<ACCOUNT_ID>:policy/p3-vprofile-instance-boundary"
      ]
    },
    {
      "Sid": "DenySelfAndCliChanges",
      "Effect": "Deny",
      "Action": [
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:UpdateAssumeRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:DeleteRolePermissionsBoundary",
        "iam:DeleteRole",
        "iam:PutUserPolicy",
        "iam:DeleteUserPolicy",
        "iam:AttachUserPolicy",
        "iam:DetachUserPolicy",
        "iam:DeleteUser"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-terraform",
        "arn:aws:iam::<ACCOUNT_ID>:user/p3-cli"
      ]
    },
    {
      "Sid": "DenyRemovingBoundaryFromProjectRoles",
      "Effect": "Deny",
      "Action": [
        "iam:DeleteRolePermissionsBoundary"
      ],
      "Resource": [
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy",
        "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-instance-role"
      ]
    }
  ]
}
```

## 2026-10-23 review-only drafts (deploy and instance roles)

Added after the sections above. Review-only; none is active or applied. `<ACCOUNT_ID>` remains a placeholder. At this point in the chronology, the two earlier boundary drafts still reflected broader policies; they are superseded by the 2026-10-23 redrafted boundaries at the end of this file. The environment `sub` string and the session document remain unverified.

### Deploy-role trust policy (Environment `production`, `main` only)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowGitHubProductionFromMainOnly",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:dmncfrncsc@104504982/cicd-pipeline-vprofile@1399501719:environment:production",
          "token.actions.githubusercontent.com:ref": "refs/heads/main",
          "token.actions.githubusercontent.com:environment": "production",
          "token.actions.githubusercontent.com:repository_owner_id": "104504982",
          "token.actions.githubusercontent.com:repository_id": "1399501719"
        }
      }
    }
  ]
}
```

### Deploy-role permission policy v1 (assumes the `aws_ssm` plugin)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WarBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
    },
    {
      "Sid": "WarBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9"
    },
    {
      "Sid": "TransferBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/*"
    },
    {
      "Sid": "TransferBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
    },
    {
      "Sid": "StartSessionOnTaggedInstances",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": {
        "StringEquals": { "ssm:resourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "StartSessionDocumentUnverified",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:document/SSM-SessionManagerRunShell"
    },
    {
      "Sid": "OwnSessionsOnly",
      "Effect": "Allow",
      "Action": [
        "ssmmessages:OpenDataChannel",
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": "arn:aws:ssm:*:*:session/${aws:userid}-*"
    },
    {
      "Sid": "SessionReadOnly",
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ssm:DescribeInstanceProperties",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

### Instance-role trust policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEc2ServiceToAssume",
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Instance-role permission policy v2 (SSM agent actions only)

`ssm:GetParameter` and `ssm:GetParameters` were removed from the copied agent list. If the agent fails to register on the first test, check those two actions first.

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
    }
  ]
}
```

### Statement to add to the option-B durable policy (option 2)

Not yet merged into a full durable-policy JSON. The author-supplied size recheck includes this statement and estimates the durable policy plus the state policy at about 6,101 compact characters; the applicable AWS limit and counting method were not verified. Recheck if either policy changes.

```json
{
  "Sid": "DenyDeployRoleTrustChanges",
  "Effect": "Deny",
  "Action": ["iam:UpdateAssumeRolePolicy", "iam:DeleteRole"],
  "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy"
}
```

## 2026-10-23 redrafted permissions boundaries (review-only, planning)

Both boundaries now equal the narrowed role permission policies. They are drafts, not applied, and nothing here is approved for implementation. Under option B a boundary change needs a separately approved root session, so neither includes guessed headroom. A missing action found in testing should be added deliberately.

Remaining validation points:
- The current [`amazon.aws.aws_ssm` documentation](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ssm_connection.html) states that the controller uses presigned URLs for S3 transfers, so the managed instance needs no S3 IAM credentials for that documented path. The project’s selected collection version, plugin configuration, and end-to-end transfer path have not been verified. The instance still needs network access to S3 and `curl`; those prerequisites have not been checked on the proposed AMI. If implementation uses a different transfer path, reassess the instance role and boundary before any apply.
- The ephemeral layer must tag the instance `Project=p3-vprofile`, or `StartSessionOnTaggedInstances` will not match.
- AWS documents the `${aws:userid}` session ARN pattern; the exact match for the GitHub role’s chosen session name remains unverified. Check the session name set in the workflow’s credentials step.
- Whether `SSM-SessionManagerRunShell` exists in the new account and is the document the plugin will use remains unverified.
- The policy size limit for customer-managed policies was not checked.

### Instance-role permissions boundary (redrafted)

Equals instance permission policy v2: SSM agent actions only. `ssm:GetParameter` and `ssm:GetParameters` are excluded.

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
    }
  ]
}
```

### Deploy-role permissions boundary (redrafted)

Exact copy of deploy permission policy v1 (8 statements). `<ACCOUNT_ID>` remains a placeholder.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WarBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
    },
    {
      "Sid": "WarBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:ListBucketVersions", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-war-k7m3q9"
    },
    {
      "Sid": "TransferBucketObjects",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/*"
    },
    {
      "Sid": "TransferBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9"
    },
    {
      "Sid": "StartSessionOnTaggedInstances",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": {
        "StringEquals": { "ssm:resourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "StartSessionDocumentUnverified",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:document/SSM-SessionManagerRunShell"
    },
    {
      "Sid": "OwnSessionsOnly",
      "Effect": "Allow",
      "Action": [
        "ssmmessages:OpenDataChannel",
        "ssm:TerminateSession",
        "ssm:ResumeSession"
      ],
      "Resource": "arn:aws:ssm:*:*:session/${aws:userid}-*"
    },
    {
      "Sid": "SessionReadOnly",
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus",
        "ssm:DescribeInstanceProperties",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

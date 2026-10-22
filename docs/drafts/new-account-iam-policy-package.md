# New-account IAM policy draft package

**Status: review-only drafts, not applied. Updated 2026-10-22.** This package preserves the 15-statement durable-layer reconstruction, a separate 14-statement option-B reconstruction derived from it, and the latest earlier full deploy and instance boundary JSONs from author-supplied material. The original reported 14-statement policy was not recovered. These texts are documentation for continued review, not deployable policy files or approval to create or change AWS resources.

Replace `<ACCOUNT_ID>` only in a private working copy if a later, separately approved implementation requires it. Never put the real account ID in this public repository.

## Decisions and limits

- The author first approved Terraform creating and managing the two named boundary policies as a planning decision, then chose option B on 2026-10-22, superseding it: the boundaries are planned to be created outside `p3-terraform` in a separately approved root session. The preserved 15-statement reconstruction below retains the superseded `ManageTwoBoundaryPolicies` statement; the separate option-B revision at the end removes only that statement. Both remain reconstructions, and the 14-statement revision is not the unrecovered original JSON. This does not approve applying these drafts or starting a root session.
- The preserved `ManageTwoNamedRoles` statement includes `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` on the project roles. Option B removes Terraform's ability to edit boundary-policy text, but not its ability to change the roles' permission policies or trust. The effective impact is unverified, depends on the undrafted role/trust policies and boundary controls, and has not been explicitly accepted; see the [new-account design decision](../decisions/new-account-deployment-design.md).
- The durable policy includes `s3:PutBucketPolicy` on the WAR and Ansible-transfer buckets. The author’s explicit acceptance of that exposure is not recorded; it remains undecided. The separate temporary acceptance for the bootstrap state-bucket policy does not apply to these two buckets.
- The 15-statement durable policy is a reconstruction from an earlier 11-statement draft and later summarized additions. It is not the unrecovered original 14-statement text. The boundary policies are the latest earlier full drafts present in the author-supplied material; no newer complete boundary JSON was present there.
- The deploy boundary’s `SsmDocumentsUnverified` statement allows broad SSM document resources. `SsmOwnSessionsOnly` uses an unverified `${aws:userid}` session pattern. The instance boundary allows `ssm:GetParameter` and `ssm:GetParameters` on `*`. Review these before implementation.
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

## Deploy-role permissions boundary draft

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

## Instance-role permissions boundary draft

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
- `SsmDocumentsUnverified` in the deploy boundary still allows broad SSM document resources. This remains unresolved and must be narrowed before any application.
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

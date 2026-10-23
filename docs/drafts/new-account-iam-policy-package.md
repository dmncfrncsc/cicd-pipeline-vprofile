# New-account IAM policy draft package

**Status: review-only drafts, not applied. Updated 2026-10-23.** This package preserves the 15-statement durable-layer reconstruction, a separate 14-statement option-B reconstruction derived from it, two earlier full boundary drafts marked superseded, the redrafted boundaries, and review-only ephemeral state, networking, and compute policy statements. The original reported 14-statement policy was not recovered. These texts are documentation for continued review, not deployable policy files or approval to create or change AWS resources.

Replace `<ACCOUNT_ID>` only in a private working copy if a later, separately approved implementation requires it. Never put the real account ID in this public repository.

## Decisions and limits

- The author first approved Terraform creating and managing the two named boundary policies as a planning decision, then chose option B on 2026-10-22, superseding it: the boundaries are planned to be created outside `p3-terraform` in a separately approved root session. The preserved 15-statement reconstruction below retains the superseded `ManageTwoBoundaryPolicies` statement; the separate option-B revision at the end removes only that statement. Both remain reconstructions, and the 14-statement revision is not the unrecovered original JSON. This does not approve applying these drafts or starting a root session.
- The preserved `ManageTwoNamedRoles` statement includes `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` on the project roles. The author chose the option-2 review direction: a root-attached deny is planned for deploy-role trust updates and deletion, while the instance role remains under Terraform as an accepted planning trade-off. Effective permissions remain unverified because the complete attached policy set and boundary behavior have not been checked; see the [new-account design decision](../decisions/new-account-deployment-design.md).
- Resolved 2026-10-23 (planning only): `s3:PutBucketPolicy` is removed from `ManageDurableBuckets` in the option-B copy, and root applies the HTTPS-only policies on the two durable buckets. This 15-statement reconstruction still contains the action as a historical record. The bootstrap state-bucket acceptance is separate.
- The 15-statement durable policy is a reconstruction from an earlier 11-statement draft and later summarized additions. It is not the unrecovered original 14-statement text. The two earlier full boundary drafts are retained below as superseded; the redrafted boundary JSON in the final section is the current review-only planning version dated 2026-10-23.
- The superseded earlier deploy boundary used `SsmDocumentsUnverified` for broad SSM document resources and `SsmOwnSessionsOnly` with a `${aws:userid}` session ARN pattern. The redrafted deploy boundary names `SSM-SessionManagerRunShell`, but its existence and use by the plugin remain unverified; the exact match between the session ARN pattern and the workflow’s chosen role-session name also remains unverified. The redrafted instance boundary excludes `ssm:GetParameter` and `ssm:GetParameters`.
- SSE-S3 for both durable buckets and the ephemeral state key `ephemeral/terraform.tfstate` are author-selected planning choices. Supplied console text shows the `p3-terraform` trust names `p3-cli`, permits `sts:AssumeRole`, and requires MFA; the no-MFA case, `p3-cli` permissions, and effective permissions remain unchecked. The ephemeral networking, compute, and state statements are now preserved below as review-only drafts; their action/condition support and provider call path are unverified. The managed-policy split is a draft proposal, not implementation approval. `iam:PassRole` compatibility for `RunInstances` and the default EBS key remain open. See the [new-account design decision](../decisions/new-account-deployment-design.md).
- Author-supplied terminal output measured draft text at 4,427 compact characters for the option-B policy, 1,407 for the deploy boundary, 1,641 and 2,614 for the two networking fragments, and 2,035 for the compute fragment. Estimated wrapper-inclusive sizes are about 4,305 for networking and 2,085 for compute; these are estimates, not measurements of complete policy documents. The authorized 2026-10-23 check of official AWS IAM quota documentation reported a 10,240-character aggregate inline-policy limit excluding whitespace, 6,144 per customer-managed policy, and a default quota of 10 managed policies per role (maximum 25). These are draft-text measurements and documented defaults, not policy validation or the account's effective Service Quotas; boundary counting against the per-role quota remains unverified. No policy in this package is recorded as applied.

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

- `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` remain in `ManageTwoNamedRoles` for review. Under the option-2 planning choice, a root-attached deny is planned for deploy-role trust updates and deletion; the instance role remains under Terraform as an accepted planning trade-off. The supplied 2026-10-23 console text shows that the `p3-terraform` trust allows only `sts:AssumeRole` for `p3-cli` and requires MFA. The no-MFA case, `p3-cli` permissions, and effective permissions remain unchecked. This is policy-draft analysis, not a live permission check or AWS-source verification.
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
      "Action": ["s3:ListBucket"],
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

Not yet merged into a full durable-policy JSON. Author-supplied output measured the option-B JSON at 4,427 compact characters. Adding the 172-character deploy-trust deny and the previously reported 1,480-character `p3-state-bucket` policy gives an estimated subtotal of about 6,080; the two ephemeral state statements add about 450, for a rough aggregate near 6,530. The state-policy size and combined aggregate were not remeasured. AWS documentation later supplied the 10,240-character aggregate inline limit, but account-specific Service Quotas were not checked. Recalculate after the final JSON is assembled.

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
- Older plugin documentation lists five controller S3 actions. The current deploy permission policy v1 has four on the transfer bucket: `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on its object ARN, plus `s3:ListBucket` on its bucket ARN. `s3:GetBucketLocation` was removed from the transfer-bucket statement only on 2026-10-23; the WAR bucket retains it. The author chose an unversioned transfer bucket, but no live AWS bucket setting was checked. The policy lacks `s3:DeleteObjectVersion`. Keep the removal conditional on pinning `amazon.aws` 11.4.0 or rechecking the source for the chosen version.
- The ephemeral layer must tag the instance `Project=p3-vprofile`, or `StartSessionOnTaggedInstances` will not match.
- AWS documents the `${aws:userid}` session ARN pattern; the exact match for the GitHub role’s chosen session name remains unverified. Check the session name set in the workflow’s credentials step.
- Whether `SSM-SessionManagerRunShell` exists in the new account and is the document the plugin will use remains unverified.
- The 2026-10-23 authorized AWS IAM documentation check reported a 6,144-character limit per customer-managed policy and a default of 10 managed policies per role (maximum 25). The account's effective Service Quotas were not checked, and whether permissions boundaries count toward the per-role quota remains unresolved.

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
      "Action": ["s3:ListBucket"],
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

## 2026-10-23 ephemeral-layer permissions (review-only, planning)

Drafted from memory and not verified against AWS. None is active or applied. `<ACCOUNT_ID>` is a placeholder. Each block below is a list of statements, not a complete policy. To use one, wrap it in `{"Version":"2012-10-17","Statement":[ ... ]}` and put a comma between the parts of the networking policy.

Proposed structure (not separately approved): if selected, networking and compute statements would go in separate customer-managed policies attached by root, and the two state statements would go in the durable inline policy. Draft-fragment measurements and wrapper-inclusive estimates are listed under Decisions and limits above; they are not measurements of fully assembled policy documents.

Unverified, and each miss would cost a root session under option B: whether each action supports the tag conditions used; which other actions the provider calls; whether the provider tags at creation or afterward; the parameter path and ARN format; Canonical's owner ID and the `ec2:Owner` key; the default EBS key in `us-east-1`; and the account's effective Service Quotas. `iam:PassRole` for `RunInstances` is assumed to be covered by `PassOnlyTheInstanceRole` and was not re-read. No ingress permission is granted on purpose.

### Ephemeral state statements (for the durable inline policy)

```json
    {
      "Sid": "EphemeralStateObjects",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/ephemeral/terraform.tfstate"
    },
    {
      "Sid": "EphemeralStateLockObject",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::p3-vprofile-tfstate-r5w8n2/ephemeral/terraform.tfstate.tflock"
    }
```

### Networking policy, part 1 (describe, tagged creates, create-only tagging)

```json
    {
      "Sid": "EphemeralEc2Describe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeVpcs",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeSubnets",
        "ec2:DescribeRouteTables",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeNatGateways",
        "ec2:DescribeAddresses",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSecurityGroupRules",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeTags"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": { "aws:RequestedRegion": "us-east-1" }
      }
    },
    {
      "Sid": "EphemeralCreateTaggedNetworkResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:CreateSubnet",
        "ec2:CreateRouteTable",
        "ec2:CreateInternetGateway"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:route-table/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:internet-gateway/*"
      ],
      "Condition": {
        "StringEquals": { "aws:RequestTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralCreateInsideTaggedVpc",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateSubnet",
        "ec2:CreateRouteTable"
      ],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralTagOnCreateOnly",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:route-table/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:internet-gateway/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "CreateVpc",
            "CreateSubnet",
            "CreateRouteTable",
            "CreateInternetGateway"
          ],
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    }
```

### Networking policy, part 2 (NAT, Elastic IP, security group, wiring, deletes)

```json
    {
      "Sid": "EphemeralCreateNatEipAndSg",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNatGateway",
        "ec2:AllocateAddress",
        "ec2:CreateSecurityGroup"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:natgateway/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:elastic-ip/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*"
      ],
      "Condition": {
        "StringEquals": { "aws:RequestTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralNatAndSgUseExistingTaggedResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNatGateway",
        "ec2:CreateSecurityGroup"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:elastic-ip/*"
      ],
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralTagOnCreateNatEipSg",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:natgateway/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:elastic-ip/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "CreateNatGateway",
            "AllocateAddress",
            "CreateSecurityGroup"
          ],
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralWireNetworkTaggedOnly",
      "Effect": "Allow",
      "Action": [
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:ModifyVpcAttribute",
        "ec2:ModifySubnetAttribute"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:route-table/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:internet-gateway/*"
      ],
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralSecurityGroupEgressOnly",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupEgress"
      ],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*",
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralDeleteTaggedNetworkResources",
      "Effect": "Allow",
      "Action": [
        "ec2:DeleteVpc",
        "ec2:DeleteSubnet",
        "ec2:DeleteRouteTable",
        "ec2:DeleteInternetGateway",
        "ec2:DeleteNatGateway",
        "ec2:DeleteSecurityGroup",
        "ec2:ReleaseAddress"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:vpc/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:route-table/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:internet-gateway/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:natgateway/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:elastic-ip/*"
      ],
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    }
```

### Compute policy (Ubuntu AMI lookup, RunInstances, instance management)

```json
    {
      "Sid": "EphemeralComputeDescribe",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:DescribeVolumes",
        "ec2:DescribeImages"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": { "aws:RequestedRegion": "us-east-1" }
      }
    },
    {
      "Sid": "EphemeralReadCanonicalAmiParameter",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:us-east-1::parameter/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
    },
    {
      "Sid": "EphemeralRunInstanceCreatedResources",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:network-interface/*"
      ],
      "Condition": {
        "StringEquals": { "aws:RequestTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralRunInstanceUseTaggedNetwork",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:subnet/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group/*"
      ],
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "EphemeralRunInstanceCanonicalImageOnly",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:us-east-1::image/*",
      "Condition": {
        "StringEquals": { "ec2:Owner": "<CANONICAL_ACCOUNT_ID>" }
      }
    },
    {
      "Sid": "EphemeralTagOnRunInstances",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "RunInstances",
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralManageTaggedInstances",
      "Effect": "Allow",
      "Action": [
        "ec2:TerminateInstances",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyInstanceMetadataOptions",
        "ec2:ModifyInstanceCreditSpecification"
      ],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": {
        "StringEquals": { "ec2:ResourceTag/Project": "p3-vprofile" }
      }
    }
```

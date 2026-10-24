# New-account IAM policy draft package

**Status: repository policy texts are review artifacts, not general verified copies of live AWS policies. Updated 2026-10-24.** This package preserves the 15-statement durable-layer reconstruction, a separate 14-statement option-B reconstruction derived from it, two earlier full boundary drafts marked superseded, the redrafted boundaries, review-only ephemeral state/networking/compute policy statements, and the two durable-bucket HTTPS-only policy drafts. The original reported 14-statement policy was not recovered. In the separately approved 2026-10-23 owner session, the author reports creating AWS policies named `p3-vprofile-deploy-boundary` and `p3-vprofile-instance-boundary` and attaching an inline policy named `p3-terraform-durable` to `p3-terraform`. The boundary names/counts and durable policy name/count were reported; the durable Sid list was supplied before saving, not repeated in its saved-policy read-back. The saved IAM JSON for those objects was not compared line by line with these local files. In the separately approved 2026-10-24 session 2, both bucket-policy saves were reported. The WAR policy's read-back text was reported matching its draft. For transfer, a successful save banner and pasted JSON matching the draft were reported, but the source does not establish whether that JSON came from the editor or a fresh saved-policy read-back. The transfer Block Public Access screenshot description omitted the bucket name. The local policy texts therefore remain review artifacts, not verified snapshots of either live policy. The networking and compute drafts remain unapplied. Complete assembled IAM candidates and their measured sizes are in [new-account-assembled-iam-policy-candidates.md](new-account-assembled-iam-policy-candidates.md). These texts do not approve any further AWS change.

Replace `<ACCOUNT_ID>` only in a private working copy if a later, separately approved implementation requires it. Never put the real account ID in this public repository.

## Decisions and limits

- The author first approved Terraform creating and managing the two named boundary policies as a planning decision, then chose option B on 2026-10-22, superseding it: the boundaries are created outside `p3-terraform` and Terraform. On 2026-10-23, the author chose to create both during initial owner setup and later reported creating them during separately approved session 1, before Terraform creates their roles. Their reported names, counts, and Sids do not establish line-by-line content or effective permissions. The preserved 15-statement reconstruction below retains the superseded `ManageTwoBoundaryPolicies` statement; the separate option-B revision removes only that statement. Both remain reconstructions, and the 14-statement revision is not the unrecovered original JSON. The bounded session 2 separately approved on 2026-10-24 is reported complete; that approval does not cover another root session or future AWS work.
- The preserved `ManageTwoNamedRoles` statement includes `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` on the project roles. The author chose the option-2 review direction: the local durable candidate includes a root-attached deny for deploy-role trust updates and deletion, while the instance role remains under Terraform as an accepted planning trade-off. Session 1 reports attaching a 17-statement durable inline policy, but the saved JSON was not compared line by line, so the presence and effect of that deny in AWS are not confirmed. Effective permissions remain unverified because the complete attached policy set and boundary behavior have not been checked; see the [new-account design decision](../decisions/new-account-deployment-design.md).
- Resolved 2026-10-23 (planning only): `s3:PutBucketPolicy` is removed from `ManageDurableBuckets` in the option-B copy, and the owner applies the saved HTTPS-only policies to the two durable buckets after their creation. This 15-statement reconstruction still contains the action as a historical record. The bootstrap state-bucket acceptance is separate.
- The 15-statement durable policy is a reconstruction from an earlier 11-statement draft and later summarized additions. It is not the unrecovered original 14-statement text. The two earlier full boundary drafts are retained below as superseded; the redrafted boundary JSON in the final section is the current review-only planning version dated 2026-10-23.
- The superseded earlier deploy boundary used `SsmDocumentsUnverified` for broad SSM document resources and `SsmOwnSessionsOnly` with a `${aws:userid}` session ARN pattern. The redrafted deploy boundary names `SSM-SessionManagerRunShell`, but its existence and use by the plugin remain unverified; the exact match between the session ARN pattern and the workflow’s chosen role-session name also remains unverified. The redrafted instance boundary excludes `ssm:GetParameter` and `ssm:GetParameters`.
- SSE-S3 for both durable buckets and the ephemeral state key `ephemeral/terraform.tfstate` are author-selected planning choices. In session 1, the author reports attaching only the durable inline policy to `p3-terraform`; networking and compute policy drafts are deferred until the ephemeral stage. The networking/compute managed-policy split remains a proposal, not separately approved. `<ACCOUNT_ID>` stays in Git; substituted copies were reported prepared in a private folder outside the repository, but the exact file-to-clipboard command was not confirmed for each policy. Supplied console text shows the `p3-terraform` trust names `p3-cli`, permits `sts:AssumeRole`, and requires MFA; the no-MFA case, `p3-cli` permissions, and effective permissions remain unchecked. The source-review status and remaining S3/provider gaps for the ephemeral drafts are detailed below and in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md). `iam:PassRole` compatibility with the actual provider call path and the default EBS key remain open. See the [new-account design decision](../decisions/new-account-deployment-design.md) and [source-review record](../../PROGRESS-HISTORY.md).
- **GitHub trust prefix (reported from author-supplied read-only CLI output, 2026-10-23):** the returned `sub_claim_prefix` matches the immutable owner/repository prefix in the deploy trust draft. The endpoint does not return the Environment suffix; `:environment:production` remains unconfirmed until a workflow emits a claim. No GitHub setting was changed.
- The assembled local candidates measure 4,970 compact characters for the 17-statement durable inline policy, 4,295 for the 10-statement networking proposal, and 2,084 for the 7-statement compute proposal. The measured inline aggregate is 6,450 including the existing `p3-state-bucket` policy at 1,480. Earlier fragment-only sizes are retained where the fragments are recorded, but the wrapper estimates are superseded by these assembled measurements. AWS quota documentation reports 10,240 characters for aggregate inline policies excluding whitespace, 6,144 per customer-managed policy, and a default of 10 managed policies per role (maximum 25). These are text-size checks and documented defaults, not IAM validation or the account's effective Service Quotas; boundary counting remains unverified. Session 1 reports the expected boundary names/counts and durable inline policy name/count. The durable Sid list matched the local candidate before saving, but was not repeated in that saved-policy read-back; no saved IAM JSON was compared line by line. Both HTTPS-only bucket-policy saves are reported; the WAR read-back was described as matching its draft, while fresh transfer saved-policy read-back is unclear. Networking and compute drafts remain unapplied.

## 2026-10-23 durable-bucket HTTPS-only policies (review-only)

The following complete drafts are reconstructed (not verbatim copies) from the bootstrap state-bucket policy in [`infra/bootstrap/main.tf`](../../infra/bootstrap/main.tf), with the durable bucket ARNs substituted. Each denies `s3:*` for any principal when `aws:SecureTransport` is `false`; both the bucket ARN and its `/*` object ARN are listed. Because `Principal` is `*`, the deny also covers the account owner; ordinary AWS CLI and console requests use HTTPS, but this is not an access test. Both policies were reported saved during the separately approved session 2. The WAR console read-back text was described as matching its draft; for transfer, the save banner and pasted JSON matched the draft, but a fresh saved-policy read-back is not established. These local texts remain review artifacts rather than authoritative snapshots of live bucket policy state. A policy read-back confirms stored text, not an actual HTTP request test. The session's completion does not authorize future AWS actions or bucket use.

### WAR bucket `p3-vprofile-war-k7m3q9`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::p3-vprofile-war-k7m3q9",
        "arn:aws:s3:::p3-vprofile-war-k7m3q9/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

### Ansible transfer bucket `p3-vprofile-ansible-transfer-k7m3q9`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyInsecureTransport",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9",
        "arn:aws:s3:::p3-vprofile-ansible-transfer-k7m3q9/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

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

- `iam:PutRolePolicy` and `iam:UpdateAssumeRolePolicy` remain in `ManageTwoNamedRoles` for review. Under the option-2 planning choice, the local durable candidate includes a root-attached deny for deploy-role trust updates and deletion; the instance role remains under Terraform as an accepted planning trade-off. Session 1 reports attaching a 17-statement durable inline policy, but its saved text was not compared line by line, so whether that deny is present in AWS is unconfirmed. The supplied 2026-10-23 console text shows that the `p3-terraform` trust allows only `sts:AssumeRole` for `p3-cli` and requires MFA. The no-MFA case, `p3-cli` permissions, and effective permissions remain unchecked. This is policy-draft analysis, not a live permission check or AWS-source verification.
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

This deny statement and the two ephemeral state statements are included in the assembled [durable inline policy candidate](new-account-assembled-iam-policy-candidates.md#durable-inline-policy-candidate): 17 statements and 4,970 compact characters. The separate `p3-state-bucket` inline policy measured 1,480, for a 6,450-character text aggregate. The aggregate is measured from supplied draft/console text, not validated against AWS; effective Service Quotas remain unchecked. The JSON below remains the source fragment for the assembled candidate.

```json
{
  "Sid": "DenyDeployRoleTrustChanges",
  "Effect": "Deny",
  "Action": ["iam:UpdateAssumeRolePolicy", "iam:DeleteRole"],
  "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy"
}
```

## 2026-10-23 redrafted permissions boundaries (review-only, planning)

Both local boundary JSON documents equal the narrowed role permission policies. They remain review artifacts: session 1 reports that AWS policies with the corresponding names and expected counts/Sids were created, but the saved JSON was not compared line by line. The policies are not yet attached to project roles. Under option B a boundary change needs a separately approved owner session, so neither includes guessed headroom. A missing action found in testing should be added deliberately.

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

Drafted from memory. Author-supplied AWS service-reference JSON outputs dated 2026-10-23 report checks of EC2 action/resource/condition support for the networking and compute fragments and selected IAM/SSM action shapes. The S3 state/lock statements were not checked, and none of the drafts was tested in AWS or against Terraform provider calls. No statement here is active or applied. `<ACCOUNT_ID>` is a placeholder. The [assembled candidates](new-account-assembled-iam-policy-candidates.md) wrap these source fragments into complete JSON documents; the networking and compute split remains a proposal.

Proposed structure (not separately approved): if selected, networking and compute statements would go in separate customer-managed policies attached by root, and the two state statements would go in the durable inline policy. See the linked candidate file for the complete documents and measurements.

Remaining validation points (review-only; the service reference describes IAM support, not actual AWS or provider behavior):
- The two S3 state/lock statements, including the `.tflock` object name, were not checked against the Terraform S3 backend documentation.
- Terraform's actual API calls and tag timing are unknown. In `RunInstances`, the instance, volume, and network interface each need the `Project` request tag; whether the provider supplies all three in the same call is unverified. Security-group-rule tagging is also unverified.
- `ModifyInstanceAttribute` supports instance, security-group, and volume resources; the draft grants only the instance. Whether the planned configuration needs the other two resource types is unknown. The `RunInstances` reference lists resource types beyond the draft's current scopes, including key-pair, launch-template, placement-group, spot-request, and group rows. These are examples, not a complete list; which resource rows the planned request requires is unknown, so do not add grants until the request shape is established.
- The public SSM parameter ARN pattern is reported, but its account segment remains unverified. The `ec2:Owner` condition key is supported for image authorization, but the Canonical owner value has only second-hand support and remains a placeholder under the public account-ID safeguard.
- `iam:PassRole` is scoped to the instance-role ARN, and the IAM reference output lists role as its resource type and `iam:PassedToService`/`iam:AssociatedResourceArn` as supported keys. Which PassRole check the provider invokes, and whether a service condition should be used for that call path, remain unresolved.
- `iam:ListInstanceProfileTags` is not in `ManageInstanceProfile`; add it only if provider evidence shows it is needed. The option-B draft already places `iam:ListInstanceProfilesForRole` in a separate role-scoped statement, so no resource-scope edit is indicated.
- The default EBS key in `us-east-1` and the account's effective Service Quotas remain unchecked. No ingress permission is granted on purpose.

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

# New-account assembled IAM policy candidates

**Status: session 3 creation and attachment of the networking and compute managed policies to `p3-terraform` are author-reported. The local JSON remains a review artifact: the full saved AWS policies were not compared line by line, and effective permissions are untested. Assembled 2026-10-23 from the source fragments in [the IAM draft package](new-account-iam-policy-package.md); the networking candidate was updated 2026-10-24 from its review-only fragments.**

These complete JSON documents make the current draft structure easy to review and measure. The source fragments remain in the package; if they change, regenerate and recheck these assembled copies. JSON parsing and size checks do not prove that AWS IAM accepts the policies, that the permissions are sufficient or least-privilege, or that provider calls match them.

The durable document is an assembly of the 14-statement option-B reconstruction, the deploy-role trust deny, and the two ephemeral-state statements. It is not the unrecovered original 14-statement policy. The author reports attaching an AWS inline policy named `p3-terraform-durable` and reading back a count of 17 statements. The candidate's Sid list was reported before saving, not repeated in the saved-policy read-back; the saved AWS JSON was not compared line by line, so this file is not a confirmed copy of the live policy. The networking and compute policies are reported created and attached as separate managed policies during session 3; the saved JSON was not compared line by line with these candidates, and effective permissions are untested. `<ACCOUNT_ID>` remains a placeholder. No account ID or `p3-state-bucket` policy text is included. See the [new-account design decision](../decisions/new-account-deployment-design.md) for the sequence and rationale.

Measurements below exclude whitespace, matching the documented AWS policy character-count method. The 6,450-character aggregate is the assembled durable document (4,970) plus the separately measured existing `p3-state-bucket` inline policy (1,480); only the first document is reproduced here. AWS documentation reports a 10,240-character aggregate inline-policy limit and 6,144 per customer-managed policy. These are documented defaults, not confirmation of this account’s effective Service Quotas.

## Durable inline policy candidate

17 statements; 4,970 compact characters.

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
    },
    {
      "Sid": "DenyDeployRoleTrustChanges",
      "Effect": "Deny",
      "Action": [
        "iam:UpdateAssumeRolePolicy",
        "iam:DeleteRole"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/p3-vprofile-deploy"
    },
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
  ]
}
```

## Networking customer-managed policy candidate

13 statements; 5,064 compact characters (whitespace excluded; measured 2026-10-24).

```json
{
  "Version": "2012-10-17",
  "Statement": [
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
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
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
        "StringEquals": {
          "aws:RequestTag/Project": "p3-vprofile"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
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
    },
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
        "StringEquals": {
          "aws:RequestTag/Project": "p3-vprofile"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralSecurityGroupRuleEgressCreate",
      "Effect": "Allow",
      "Action": "ec2:AuthorizeSecurityGroupEgress",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group-rule/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralTagSgRuleAtCreate",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group-rule/*",
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": "AuthorizeSecurityGroupEgress",
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralChangeTagsOnProjectSgRules",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:security-group-rule/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Project": "p3-vprofile"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
      }
    }
  ]
}
```

## Compute customer-managed policy candidate

8 statements; 2,233 compact characters (whitespace excluded; measured 2026-10-24).

```json
{
  "Version": "2012-10-17",
  "Statement": [
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
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
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
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralRunInstanceNetworkInterface",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:network-interface/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
      }
    },
    {
      "Sid": "EphemeralRunInstanceCanonicalImageOnly",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:us-east-1::image/*",
        "arn:aws:ec2:us-east-1::snapshot/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Owner": "<CANONICAL_ACCOUNT_ID>"
        }
      }
    },
    {
      "Sid": "EphemeralTagOnRunInstances",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
        "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:volume/*"
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
        "StringEquals": {
          "ec2:ResourceTag/Project": "p3-vprofile"
        }
      }
    }
  ]
}
```

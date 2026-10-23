# Planning decision: New-account Project 3 deployment design

**Status:** The design baseline and cost gate were accepted by the author on 2026-10-22 for planning, using existing estimates and their stated limits. This record does not approve implementation, spending, root sign-in, or AWS changes. No new-account application resources or IAM drafts are recorded as applied.

## Problem and constraints

Project 3's earlier Phase D design applied to a different account and cannot be carried into the new account as approval. The new-account plan must keep the state bucket separate from application teardown, stay within the account and credit safeguards, avoid public WAR distribution, and make the running application stack inexpensive to stop between sessions. The new-account design also needs its own cost and implementation gates.

## Planning baseline

Use the existing bootstrap Terraform root for the state bucket. Add separate durable and ephemeral application roots with separate state keys. The durable state key `durable/terraform.tfstate` was proposed; the backend key must match the final configuration. The ephemeral key remains to be specified before PR 2.

| Layer | Planned ownership | Lifecycle |
| --- | --- | --- |
| Bootstrap | Existing Project 3 state bucket and bootstrap settings | Remains separate; not part of application teardown |
| Durable | WAR bucket, Ansible-transfer bucket, GitHub OIDC provider, deploy role, instance role and profile; role-specific boundary policies are referenced by ARN but created outside this layer (see the boundary-policy ownership decision) | Retained between sessions; removed only during separately approved project teardown |
| Ephemeral | VPC, private subnet, routing, NAT path, security group with no inbound rules, and one EC2 instance | Created for a work session and destroyed afterward; destroy must not affect durable resources or IAM |

The deployment flow is planned as GitHub Actions building the WAR, uploading it to the private WAR bucket, Ansible running from the GitHub runner over SSM using the transfer bucket, a health check, and rollback to a prior WAR version. This flow is not implemented or verified in the new account.

## Planning choices and trade-offs

- **One `t3.large` and a 20-GiB encrypted gp3 root volume.** One host is easier to manage than four `t3.small` instances with similar total memory. Capacity is unverified, and sustained CPU use may incur surplus-credit charges.
- **Private subnet with NAT.** This avoids a public address on the instance and preserves the planned outbound package path. NAT access to package repositories has not been verified in the new account. Three interface endpoints were estimated cheaper for short sessions, but required endpoint coverage and package-site access are unknown; the public-subnet option is cheaper but exposes a public address. See the dated estimates and source limits in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md).
- **Defer S3 server access logging.** Keep the two Medium `terraform:S6258` findings Open; do not mark them Accepted or resolved. This avoids adding a logging destination and its cost now, but leaves the logging findings open for later review.
- **Run Ansible from the GitHub runner over SSM.** This avoids SSH ingress and keeps deployment within the proposed workflow. The runner plugin, exact SSM documents, network path, and interrupted-run behavior remain unverified.
- **Defer Jenkins until GitHub Actions deployment works.** Jenkins remains required before Project 3 is complete; J1 versus J2 is undecided. The long-term direction is parity with one platform operating the flow at a time, not simultaneous deployment.

The author accepted the cost gate on 2026-10-22 using the existing planning estimates; this is not a current quote or verified workload cost. The N. Virginia NAT rate was not confirmed, the gp3 source used GB-month while the estimate used GiB-month, and the S3 regional rate was not directly visible in the reviewed source. The design records an 8-hour session as an assumption, while the historical comparison in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md) shows 48-hour and 730-hour examples; the supplied record does not establish which duration underlay the accepted cost gate. Credit eligibility is unknown, and no budget exists. The design excludes the known Organization, Control Tower, and Identity Center actions, but this does not guarantee that charges are credit-covered or that credits will not expire for another reason. The estimates and source qualifications are preserved in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md).

## PR 1 IAM planning direction

The draft direction uses exact resource names and two role-specific permissions boundaries so the deploy role and instance role do not share one union of allowed actions. A boundary limits the role policy; it does not grant permissions by itself. The instance role and profile are planned for the durable layer so an ephemeral destroy does not remove IAM. The proposed names are:

- Buckets: `p3-vprofile-war-k7m3q9` and `p3-vprofile-ansible-transfer-k7m3q9`.
- Roles: `p3-vprofile-deploy` and `p3-vprofile-instance-role`.
- Instance profile: `p3-vprofile-instance-profile`.
- Boundaries: `p3-vprofile-deploy-boundary` and `p3-vprofile-instance-boundary`.

The durable-bucket policy direction removes `s3:PutBucketPublicAccessBlock` while retaining `s3:GetBucketPublicAccessBlock`. The durable root is not to declare an `aws_s3_bucket_public_access_block` resource, so Terraform will not detect later drift in those settings. After PR 1, read back all four Block Public Access settings on both buckets; the account-level settings are unchecked and must not be treated as a backstop.

The draft proposes retaining `s3:PutBucketPolicy` on only the two named durable buckets so Terraform can manage their HTTPS-only policies. This permission can weaken or replace those policies. The author-supplied material records no explicit acceptance of this separate exposure; decide before implementation whether to accept it temporarily, and if accepted, revisit it in the D2 IAM review or sooner if another person receives access to the role. The earlier acceptance applies only to the bootstrap state bucket.

The draft includes `iam:PassRole` only on `p3-vprofile-instance-role` because AWS documents that `AddRoleToInstanceProfile` requires it. The 2026-10-23 source check also found an AWS Systems Manager Quick Setup example with a separate `iam:PassRole` grant conditioned on `iam:PassedToService = ec2.amazonaws.com`; it does not establish which calls the Terraform provider makes in this project. No target-service condition was added pending confirmation of the provider's call path. The policy has not been applied or tested. See the 2026-10-23 source-check entry in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md).

**Boundary-policy ownership decision (2026-10-22, revised):** The author first approved Terraform creating and managing the two named customer-managed boundary policies from the durable layer as a planning decision, then chose option B, superseding that choice. `p3-terraform` will not create or edit the two boundary policies. Allowing it to edit boundary text would let it raise the permissions ceiling for the project roles; PR review is a procedural safeguard, not an IAM restriction. The boundaries are planned to be created outside `p3-terraform` in a separately approved root session. `ManageTwoBoundaryPolicies` is removed from the separate 14-statement option-B review copy but remains in the preserved 15-statement reconstruction; `ReadBoundaryPolicies` remains, and the durable layer references the boundary ARNs without owning those policies. Later boundary changes require another separately approved root session. The draft's exact-boundary conditions and `DenyRemovingBoundaryFromProjectRoles` are intended to prevent detaching or replacing a project role's boundary, but this has not been tested. This decision is for planning only; no root session, policy, boundary, or AWS change is approved or applied.

## Open items and approval limits

- The bootstrap state role's `s3:PutBucketPublicAccessBlock` permission is a separate, undecided exposure. The current local bootstrap configuration declares the matching resource in [`infra/bootstrap/main.tf`](../../infra/bootstrap/main.tf); the durable-bucket decision above does not settle the state-bucket permission.
- Review-only trust and permission drafts for both roles and redrafted permissions boundaries now exist in the [IAM draft package](../drafts/new-account-iam-policy-package.md). The Environment subject and the session document’s existence and use by the plugin remain unverified. The new boundaries are review-only and must be finalized before any separately approved root session.
- The durable-policy draft's `DenySelfAndCliChanges` statement blocks `p3-terraform` from changing its own policy. Any needed change to that policy therefore requires a separately approved root/admin action; an `AccessDenied` result must first be checked for identity, resource, and condition causes.
- **Prior role-policy/trust review checkpoint (event date unknown; superseded by the 2026-10-23 update below):** no option had been accepted at that point. Its analysis and evidence limits are preserved in [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md).
- The [review-only IAM draft package](../drafts/new-account-iam-policy-package.md) preserves the supplied 15-statement durable-policy reconstruction, the earlier deploy/instance boundary drafts, and a separate 14-statement option-B reconstruction made by removing only `ManageTwoBoundaryPolicies`. Neither reconstruction is the unrecovered original 14-statement JSON; neither is active or applied.
- The original final 14-statement, 4,654-character policy JSON was not recovered. An earlier 11-statement durable-layer policy and two separate boundary drafts (eight deploy statements and five instance statements) were present in supplied review material; the claim that the boundaries were unchanged since v2 was not independently verified. No standalone policy file was saved at that point, and none was recorded as applied. A later 15-statement reconstruction was supplied for review; its reported size is 4,773 characters excluding whitespace. The reported combined estimate with the 1,480-character state policy was 6,253 characters for this reconstruction; the reported 14-statement figure combined with that state policy was 6,134 characters. These counts and AWS quota calculations were not independently verified. The reconstruction adds `PassOnlyTheInstanceRole`, `DurableStateObjects`, `DurableStateLockObject`, and `ManageTwoBoundaryPolicies`, and adds `s3:ListTagsForResource` to `ManageDurableBuckets`. Do not treat this reconstructed draft as the original 14-statement policy or as approved for application.
- The 14-statement option-B copy has no `Allow` or explicit `Deny` for boundary-policy editing actions in that policy text; effective access depends on the other attached policies and remains unverified. This is separate from the deploy-role trust deny chosen for review below.
- Earlier boundary findings are superseded by the 2026-10-23 redraft: the broad SSM document wildcard was replaced with the named `SSM-SessionManagerRunShell` document, whose existence and use by the plugin remain unverified; the instance boundary now excludes `ssm:GetParameter` and `ssm:GetParameters`. The AWS session ARN pattern is documented, but its exact match for the workflow’s chosen role-session name remains unverified. The bucket encryption mode is not specified; SSE-KMS would require additional KMS permissions. Confirm the actual session document and workflow session name before implementation.
- The `p3-terraform` trust policy and MFA condition are unread. The account-level S3 settings remain unchecked. The ephemeral layer's EC2/VPC/NAT/security-group permissions and state key remain undecided; confirm whether the durable-layer `iam:PassRole` grant for the instance role covers the PR 2 launch and whether it needs an EC2 service condition. The bootstrap state role's `s3:PutBucketPublicAccessBlock` permission remains a separate, undecided exposure.
- Root is reported as the only existing admin path. Under option B, a separately approved root console session is planned to create the two boundaries and attach the final reviewed durable policy to `p3-terraform`; it is not authorized. Root must not be used for Terraform. Any AWS change, root session, cost-bearing operation, or implementation still requires its separate approval.
- No Organizations, Control Tower, Identity Center, or other account-wide action is part of this plan. Do not infer credit eligibility from that exclusion.

The complete design, IAM draft, cost assumptions, and implementation plan require another review before PR 1. Each PR needs its own plan review and apply approval. Planning approval does not authorize a policy change, a root session, or an AWS operation.

## Interview explanation

"For the new account, I planned separate Terraform states for long-lived deployment resources and the short-lived application stack, so a session teardown would not remove the buckets or IAM setup. I also planned distinct permission boundaries for the deploy and instance roles, with their policy text managed outside `p3-terraform`, and documented the remaining cost and security questions. This is still a planning baseline; I have not applied the design."

## Update 2026-10-23 — deploy-role trust, runner connection, and p3-terraform scope (review only)

**Status:** planned and under review. No policy was applied, no root session was started, and no GitHub or AWS setting was changed.

### Problem

The deploy role must be usable by GitHub Actions runs from `main` only, and pull-request workflows must stay without AWS access. The same session also needed a way for Ansible on the runner to reach a private-subnet instance without SSH, and a decision on what `p3-terraform` may change on the project roles.

### Decisions

1. **GitHub Environment `production`, restricted to `main`.** The trust policy checks the audience, the environment subject, `ref`, `environment`, `repository_id` and `repository_owner_id`. This repository uses immutable subject claims (reported by the author from the repository's OIDC settings page), so subject strings carry owner and repository IDs.
2. **Working assumption: Ansible runs on the GitHub runner with the `aws_ssm` connection plugin.** Under it the deploy role needs `ssm:StartSession` and no `ssm:SendCommand`. Current `amazon.aws.aws_ssm` documentation says the controller uses presigned S3 URLs and the managed instance needs no S3 IAM credentials for that documented transfer path. The project’s selected collection version, plugin configuration, and end-to-end transfer remain unverified; the instance still needs S3 network access and `curl`.
3. **Option 2 for `p3-terraform`:** an explicit deny of `iam:UpdateAssumeRolePolicy` and `iam:DeleteRole` on `p3-vprofile-deploy`, added to the durable policy that root attaches. Blocking only the trust update would not help, because deleting and recreating the role also sets its trust.
4. **Boundary scope (planning only):** the instance boundary matches instance permission policy v2 and excludes `ssm:GetParameter` and `ssm:GetParameters`; the deploy boundary is an exact copy of deploy permission policy v1 (8 statements). Neither adds headroom. Under option B, later boundary changes require a separately approved root session. The full drafts are in the [redrafted-boundaries section](../drafts/new-account-iam-policy-package.md#2026-10-23-redrafted-permissions-boundaries-review-only-planning).

### Alternatives considered

- **No Environment (branch subject only):** simpler and needs no GitHub setup, but gives no approval pause and relies on the AWS trust policy alone.
- **Option 1, accept the risk (leave `p3-terraform` able to change trust):** least work, but a stolen or mistaken session could remove the `main` and Environment checks.
- **Option 2b, root creates the deploy role and its trust:** no explicit deny is needed and Terraform only references the role, but the role sits outside Terraform state and teardown has a manual step. Not selected; may be revisited.
- **Option 3, root creates both roles:** most root sessions and manual work.
- **Sending commands with SSM documents instead of the plugin:** not selected; it would not let Ansible run from the runner.

### Consequences and accepted trade-offs

- A wrong trust policy at the first apply can be fixed only by a root session, so the environment `sub` string must be confirmed before that apply.
- Destroying the durable layer fails at the deploy role and needs a root session.
- The instance role stays fully under Terraform; that risk is accepted as part of option 2 as described.
- Both permissions boundaries were redrafted on 2026-10-23 to match the narrowed role policies, without headroom. They remain review-only and must be finalized before a separately approved root session.
- The `ref` condition and the Environment branch rule are separate controls; the Environment branch rule is a GitHub setting that `p3-terraform` cannot change, and neither replaces checking the `protect-main` ruleset.

### Evidence and limits

- **Sources read (2026-10-23):** [GitHub OIDC reference](https://docs.github.com/en/actions/reference/security/oidc); [GitHub guide for OIDC with AWS](https://docs.github.com/en/actions/how-tos/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services); [AWS IAM and STS condition context keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html); [GitHub changelog on immutable subject claims](https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-GitHub-actions-oidc-tokens/); [Ansible `amazon.aws.aws_ssm`](https://docs.ansible.com/ansible/latest/collections/amazon/aws/aws_ssm_connection.html); [Ansible `community.aws.aws_ssm` 7.2.0](https://docs.ansible.com/ansible/9/collections/community/aws/aws_ssm_connection.html); [AWS Session Manager sample policies](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-examples.html).
- **Not opened:** the AWS Access Analyzer policy-check page.
- **Unverified:** the environment `sub` string with IDs; whether `SSM-SessionManagerRunShell` exists in the new account and is used by the selected plugin configuration; the exact match between the workflow’s chosen role-session name and the `${aws:userid}` session ARN pattern; instance behavior without `ssm:GetParameter(s)`; the project’s selected `amazon.aws` collection version/configuration and end-to-end transfer; `curl` and network access on the proposed instance image; the customer-managed boundary policy size limit; and the aggregate inline-policy size with the added deny.
- **Reported only:** the immutable-subject setting and prefix, from an author-supplied screenshot.
- **Textually reviewed on 2026-10-23:** the durable-policy statements for role creation, pass-role, instance profile and boundary reads. This checked naming and consistency in the saved draft, not AWS-required actions, conditions, or effective permissions; see [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md).

### Interview answer (based on work actually done)

"I designed, but have not yet deployed, the IAM for a GitHub Actions deployment role. I found that my repository uses immutable OIDC subject claims, so my first trust draft would never have matched. I chose a GitHub Environment restricted to `main`, and I noticed that a permissions boundary limits what a role can do but not who can assume it. That meant the Terraform role could rewrite the deploy role's trust by editing or by deleting and recreating it, so I planned an explicit deny that only a root-attached policy can remove. Everything is still a reviewed draft, with the unverified parts listed."

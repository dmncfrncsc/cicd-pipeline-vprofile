# Project 3 session handoff

**Updated 2026-10-24.** Concise handoff based on local repository files and dated author-supplied evidence. Live service state may have changed since the recorded checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase: durable buckets applied; owner session 2 pending.** PR #66 added the two-bucket Terraform root. On 2026-10-24, the author separately approved applying a freshly generated saved plan; supplied Terraform output reports six resources added. Supplied AWS CLI output reports selected settings read back, but the target account match is not confirmed in the shared record. Session 2 is not authorized, and neither bucket may be used before its required protections are applied and read back. See the [new-account design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence limits.

## Current state

- **Phase 1, GitHub Actions build/test (reported complete):** recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. Later pull-request checks also passed for PR #66 and PR #67 (author-supplied screenshots/terminal output); no later push or manual run, or fresh ruleset check, is recorded. The workflow has no AWS access and keeps the WAR on the runner. See the [workflow](.github/workflows/build-test.yml), [NOTES.md](NOTES.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **New-account bootstrap (reported, 2026-10-21):** the six-resource state-bucket bootstrap was applied and migrated to S3; a later plan reported `No changes`. These are dated terminal results, not a live check. See the [bootstrap backend decision](docs/decisions/terraform-bootstrap-s3-backend.md) for backend settings and the state-metadata question.
- **Read-only AWS preflight (author-supplied terminal output, 2026-10-23):** output reported `assumed-role/p3-terraform` and access to the recorded bootstrap state bucket and state-object metadata. The account ID was redacted; the object body and bucket settings were not read, so this did not confirm account alignment, state contents, or versioning. Full scope and limits are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Durable buckets (apply and selected live reads reported 2026-10-24):** PR #66 added `infra/durable/`; the author later applied a fresh, separately approved saved plan. Supplied Terraform output reports 6 added, 0 changed, 0 destroyed, and the state list contains the six expected bucket, encryption, WAR versioning, and lifecycle addresses. Supplied AWS CLI output reports SSE-S3 (`AES256`) on both buckets, WAR versioning enabled, and the WAR noncurrent-version lifecycle rule enabled for 30 days. The transfer-bucket versioning command returned no output; the session interpreted this as versioning never enabled. The identity ARN showed `assumed-role/p3-terraform`, but the account ID was redacted and the author did not report privately confirming the intended account. Tags, public-access-block settings, bucket policies, ownership controls, and account-level S3 settings were not read back. No uploads are reported. Keep both buckets unused until session 2 applies and reads back the required protections. See the [design decision](docs/decisions/new-account-deployment-design.md) and [history](PROGRESS-HISTORY.md).
- **IAM documents:** the durable candidate and proposed networking/compute policies, including full JSON and measurements, are in [the assembled candidates](docs/drafts/new-account-assembled-iam-policy-candidates.md). The candidates are not confirmed copies of the saved AWS policies. The networking/compute managed-policy split is a proposal. See the [design decision](docs/decisions/new-account-deployment-design.md) for rationale.
- **Prior account:** paused; its bootstrap state and D1 buckets are recorded as implemented, but current resources and charges are unknown. Because of charge concerns, the author plans to defer cleanup until Project 3 is complete or near completion. No inventory or deletion is authorized. The old inventory gaps and proposed cleanup sequence are recorded in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Instruction files:** The author confirmed on 2026-10-22 that Master Prompt v4.9 and Project Instructions v3.9 are the official Project 3 guidance. Their local files now identify them as adopted; the earlier screenshot showed their placement. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Decision and approval status

| Item | Status |
| --- | --- |
| Cost gate | Accepted on planning estimates (2026-10-22); the session-duration basis and other limitations remain open in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) |
| First Terraform change | The two durable buckets were applied on 2026-10-24; author-supplied Terraform output reports 6 added, 0 changed, 0 destroyed. Account alignment remains unconfirmed in the shared record |
| Owner sessions | Session 1's IAM work and sign-out are author-reported. Session 2 is still unauthorized and must apply and read back the bucket protections before either bucket is used |
| IAM structure | Boundaries remain outside `p3-terraform` and Terraform and are not yet attached to project roles; networking/compute managed-policy split is only a proposal. Draft details and rationale are in the [design decision](docs/decisions/new-account-deployment-design.md) |
| Deployment IAM and SSM | GitHub Environment `production` on `main` and `aws_ssm` are review directions, not verified integration. OIDC subject suffix, SSM document/plugin behavior, provider calls, and effective permissions remain open |
| Jenkins | Required before completion; setup option remains undecided |

## Open risks and gaps

- **State metadata:** the 2026-10-22 check reported live S3 serial 1 and a different lineage from the preserved backup (serial 7). On 2026-10-23, `head-object` reported the same 9,174-byte size as the pre-migration backups, but that metadata match does not establish matching contents; the object body was not read and the cause of the serial/lineage difference is unknown.
- **Bootstrap IAM and S3 settings:** `s3:PutBucketPublicAccessBlock` on the bootstrap role is a separate, unaccepted issue. Account-level S3 settings are unchecked; do not rely on them as a backstop.
- **IAM review:** the local candidates are not confirmed copies of the AWS policies or proof of effective permissions. Review line-by-line content before relying on them. The complete JSON and measurements are in [the assembled candidates](docs/drafts/new-account-assembled-iam-policy-candidates.md); unresolved IAM, provider, and quota checks are tracked in the [design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **SonarCloud findings (author-reported, PR #66):** two `terraform:S6258` access-logging findings and two `terraform:S6249` HTTPS-only findings were Accepted. The author also reports that the resulting Quality Gate passed; the screenshot supporting that result was not available for independent inspection here. Accepted findings are not fixes. The `S6249` acceptance remains an open dependency: session 2 must apply and read back the HTTPS-only policies before either bucket is used.
- **Transfer-bucket retention:** the author chose an unversioned transfer bucket because deploy permission policy v1 lacks `s3:DeleteObjectVersion`. The 2026-10-24 author-supplied AWS CLI read returned no versioning status; the session interpreted this as versioning never enabled. This is a reported read, not a fresh check here. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).
- **Costs and credits:** the new-account billing and credit state were not checked, and no monthly budget exists. The 2026-10-22 cost gate used planning estimates, not a quote; session-duration assumptions, regional pricing, and workload limits remain open. Do not infer that the new account has the prior account's credit outcome. Old-account resource inventory and charges also remain unknown; see the deferred cleanup plan in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Safety boundaries

- **Terraform identity:** use WSL. Author-supplied output on 2026-10-24 showed `assumed-role/p3-terraform`, but its account ID was redacted and no private confirmation that it matched the intended account was reported. Before any future Terraform command, separately authorized, run `aws sts get-caller-identity` in the same shell and confirm both the role and intended account privately. `default` and `p3-readonly` are reported to target the prior account. The author reports clearing the temporary credentials after the 2026-10-24 reads; before another authorized session, load MFA credentials as described in [NOTES.md](NOTES.md).
- **State:** keep backups outside Git. Do not replace, restore, or destroy state to diagnose the metadata difference.
- **Account-wide actions:** do not open or use the AWS Organizations console, create or join an Organization, or set up Control Tower. Pause before any other account-wide action. See the [credit safeguard](docs/decisions/terraform-bootstrap-s3-backend.md#account-wide-actions-and-credit-safeguard).
- **Public repository and project scope:** keep Phase 1 pull-request workflows build/test only, with no AWS access. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or its workflow logs. Do not derive the pipeline from the instructor’s `Jenkinsfile` without a focused need and approval, or reuse Project 1 or 2 resources without an approved design and verified ownership.
- Documentation updates do not authorize AWS changes, spending, deployment, apply, or unrelated Git operations. The author handles staging, commit, push, and merge for this documentation milestone after Codex confirms the review is complete; exclude unrelated changes.

## Next safe step

No AWS action is authorized by this documentation update. The next step is to review the bounded session-2 checklist offline and obtain separate explicit approval before any owner-console action. Session 2 must apply the saved HTTPS-only policies and read back each policy, all four public-access-block settings on both buckets, encryption, WAR versioning and lifecycle, and transfer-bucket versioning before either bucket is used. The policy read-back confirms stored text, not actual HTTP-denial behavior. Before any further AWS work, privately confirm the intended account; the account ID in the apply-session identity output was redacted. Deployment IAM/SSM integration, networking/compute, and Jenkins come later. Old-account inventory and cleanup remain deferred and separately unauthorized.

**Session-start precondition:** the author reports that the temporary WSL credentials were cleared after the 2026-10-24 reads. Before any separately authorized future AWS CLI read or Terraform command, load credentials with `eval "$(aws configure export-credentials --profile p3-new --format env)"` (the CLI prompts for MFA), then run `aws sts get-caller-identity` in that same shell. Confirm `assumed-role/p3-terraform` and, privately, the intended account before continuing; the apply-session account ID was redacted and no private match was reported. Never rely on `default`; clear the exported credentials when finished. See [NOTES.md](NOTES.md) for the tested flow.

The OIDC subject suffix, role-session-name match, `amazon.aws` version, SSM document and transfer behavior remain deployment-stage checks. Keep `<ACCOUNT_ID>` in repository files; only use substituted policy copies in a private location after the relevant approval.


## References

- [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md): milestones and dated evidence
- [NOTES.md](NOTES.md): technical learning reference
- [README.md](README.md): repository overview
- [Decision records](docs/decisions/): [bootstrap backend](docs/decisions/terraform-bootstrap-s3-backend.md) and [new-account design](docs/decisions/new-account-deployment-design.md)
- Claude Project Knowledge copies of PROGRESS.md and PROGRESS-HISTORY.md predate the 2026-10-23 updates; refresh them only with separate explicit authorization.

Defer the full interview guide until implementation is sufficiently complete and verified. Stage-specific practice answers and evidence reminders belong in [NOTES.md](NOTES.md); distinguish tutorial-provided, pre-existing, generated, and AI-assisted work from the author's verified contributions.

## Definition of Done

- [ ] Architecture, tools, course coverage, costs, and security decisions are documented and approved before implementation.
- [x] CI build and tests have recorded successful verification (Run #1 and later trigger evidence).
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins, each with recorded verification.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified, with outcomes and limits recorded.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [ ] Deployment to the approved target and health behavior are verified.
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated; the forced CI error path turned CI red, but the original zero-test assertion and rollback behavior remain unverified.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean.

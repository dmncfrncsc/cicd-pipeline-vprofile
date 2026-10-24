# Project 3 session handoff

**Updated 2026-10-24.** Concise handoff based on local repository files and dated author-supplied evidence. Live service state may have changed since the recorded checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase: ephemeral network/compute policy and design review (planning only).** The author agreed to add two security-group-rule statements to the review-only networking candidate; no networking or compute policy is attached or approved for implementation. The local service-reference outputs are source-review evidence, not AWS or Terraform-provider validation. The S3 route remains undecided: NAT-only appears in the supplied conversation as a GPT recommendation, without a direct author acceptance. The conversation's assistant-generated summary labels a broader ephemeral baseline accepted, but the supporting author approval is not shown in the supplied excerpt. See the [design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the decision record and evidence limits.

The author also reports signing out after owner session 2 and privately confirming the intended account; neither claim is independently verifiable from the shared record. No bucket use, AWS deploy role, or application deployment is reported.

## Current state

- **Phase 1, GitHub Actions build/test (reported complete):** recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. Later pull-request checks also passed for PRs #66–#68 (author-supplied screenshots/terminal output); no later push or manual run, or fresh ruleset check, is recorded. The workflow has no AWS access and keeps the WAR on the runner. See the [workflow](.github/workflows/build-test.yml), [NOTES.md](NOTES.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **New-account bootstrap (reported, 2026-10-21):** the six-resource state-bucket bootstrap was applied and migrated to S3; a later plan reported `No changes`. These are dated terminal results, not a live check. See the [bootstrap backend decision](docs/decisions/terraform-bootstrap-s3-backend.md) for backend settings and the state-metadata question.
- **Read-only AWS preflight (author-supplied terminal output, 2026-10-23):** output reported `assumed-role/p3-terraform` and access to the recorded bootstrap state bucket and state-object metadata. The account ID was redacted; the object body and bucket settings were not read, so this did not confirm account alignment, state contents, or versioning. Full scope and limits are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Durable buckets (apply, CLI reads, and owner-session read-back reported 2026-10-24):** PR #66 added `infra/durable/`; author-supplied Terraform output reports 6 added, 0 changed, 0 destroyed. AWS CLI output reports SSE-S3 (`AES256`) on both buckets, WAR versioning enabled, and its 30-day noncurrent-version lifecycle rule. The earlier transfer-bucket versioning command returned no status; a later author-supplied console screenshot reports Versioning Disabled for `p3-vprofile-ansible-transfer-k7m3q9`. The author reports session 2 complete: the WAR bucket's four Block Public Access settings were On, no policy existed before the change, and its HTTPS-only policy was saved with text matching the draft. For the transfer bucket, the author reports all four Block Public Access settings On, though the described screenshot crop did not identify the bucket. A console success banner was reported after saving the transfer HTTPS-only policy; the pasted JSON matched the draft, but a fresh read-back of the saved policy is not established. The author reports privately confirming the intended account and signing out; the apply identity's account ID remains redacted, so neither claim can be independently checked here. Tags, ownership controls, account-level S3 settings, and actual HTTP-denial behavior remain unchecked. No bucket use is reported. See the [design decision](docs/decisions/new-account-deployment-design.md) and [history](PROGRESS-HISTORY.md).
- **IAM documents:** the durable candidate and review-only networking/compute policies, including full JSON and measurements, are in [the assembled candidates](docs/drafts/new-account-assembled-iam-policy-candidates.md). The networking candidate now has 12 statements and 4,757 compact characters. The candidates are not confirmed copies of saved AWS policies or proof of effective permissions. The networking/compute managed-policy split remains a proposal; no attachment or implementation is approved. See the [design decision](docs/decisions/new-account-deployment-design.md) for rationale and open scope questions.
- **Prior account:** paused; its bootstrap state and D1 buckets are recorded as implemented, but current resources and charges are unknown. Because of charge concerns, the author plans to defer cleanup until Project 3 is complete or near completion. No inventory or deletion is authorized. The old inventory gaps and proposed cleanup sequence are recorded in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Instruction files:** The author confirmed on 2026-10-22 that Master Prompt v4.9 and Project Instructions v3.9 are the official Project 3 guidance. Their local files now identify them as adopted; the earlier screenshot showed their placement. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Decision and approval status

| Item | Status |
| --- | --- |
| Cost gate | Accepted on planning estimates (2026-10-22); the session-duration basis and other limitations remain open in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) |
| First Terraform change | The two durable buckets were applied on 2026-10-24; author-supplied Terraform output reports 6 added, 0 changed, 0 destroyed. The apply account ID was redacted; the later private account match is author-reported and cannot be compared with the apply identity here |
| Owner sessions | Session 1's IAM work and sign-out, and session 2 completion and sign-out, are author-reported. See the durable-bucket status above for session 2's evidence limits |
| IAM structure | Boundaries remain outside `p3-terraform` and Terraform and are not yet attached to project roles; networking/compute managed-policy split is only a proposal. Two security-group-rule statements were agreed for review-only draft text; no attachment or implementation is approved. Draft details and rationale are in the [design decision](docs/decisions/new-account-deployment-design.md) |
| Deployment IAM and SSM | The `production` Environment is reported restricted to `main`; temporary workflow run #1 reported the exact `sub`, and one non-main run was blocked. The review-only AWS trust choice uses `aud` and exact `sub` only, so AWS does not enforce `main`; the Environment branch rule is the control, with administrator bypass still enabled. No role or trust policy is applied. Eight permission-policy and trust-risk planning choices are recorded, but the policy remains unapplied and its behavior untested. Provider settings and SSM/transfer behavior remain reported or unresolved; see the [design decision](docs/decisions/new-account-deployment-design.md) |
| Jenkins | Required before completion; setup option remains undecided |

## Open risks and gaps

- **State metadata:** the 2026-10-22 check reported live S3 serial 1 and a different lineage from the preserved backup (serial 7). On 2026-10-23, `head-object` reported the same 9,174-byte size as the pre-migration backups, but that metadata match does not establish matching contents; the object body was not read and the cause of the serial/lineage difference is unknown.
- **Bootstrap IAM and S3 settings:** `s3:PutBucketPublicAccessBlock` on the bootstrap role is a separate, unaccepted issue. Account-level S3 settings are unchecked; do not rely on them as a backstop.
- **IAM review:** the local candidates are not confirmed copies of the AWS policies or proof of effective permissions. The rule-tag draft omits `ec2:CreateAction` by choice and does not constrain `aws:TagKeys`; it may tag existing rules and does not exclude extra tag keys in a request containing `Project = p3-vprofile`. Provider call and tag timing remain unknown. Review this scope and the other IAM/provider questions before any Gate A decision; details are in the [design decision](docs/decisions/new-account-deployment-design.md), [policy package](docs/drafts/new-account-iam-policy-package.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **SonarCloud findings (author-reported):** the two durable-bucket `terraform:S6258` access-logging findings and two `terraform:S6249` HTTPS-only findings were Accepted; the main-branch bootstrap `terraform:S6258` finding was later accepted with a stated reason, after which the author reports the gate turned green. Acceptance is not a fix. The reason comment is unconfirmed, three CSS findings in `vprofile-src` remain Open, coverage is not configured, and the “1 analysis warning” text has not been read. Whether to analyze the public submodule remains undecided. The durable-bucket policy read-back limitations and absence of an actual HTTP-denial test remain as recorded in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Transfer-bucket retention:** the author chose an unversioned transfer bucket because deploy permission policy v1 lacks `s3:DeleteObjectVersion`. The earlier 2026-10-24 AWS CLI read returned no versioning status; a later author-supplied console screenshot reports `Disabled` for the named transfer bucket. This is reported evidence, not a fresh check here. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).
- **Costs and credits:** the new-account billing and credit state were not checked, and no monthly budget exists. The 2026-10-22 cost gate used planning estimates, not a quote; session-duration assumptions, regional pricing, and workload limits remain open. Do not infer that the new account has the prior account's credit outcome. Old-account resource inventory and charges also remain unknown; see the deferred cleanup plan in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Safety boundaries

- **Terraform identity:** use WSL. Author-supplied output on 2026-10-24 showed `assumed-role/p3-terraform`, but the apply account ID was redacted. The author later reported privately matching the intended account during session 2; this does not let the shared record compare the apply identity with that account. Before any future Terraform command, separately authorized, run `aws sts get-caller-identity` in the same shell and confirm both the role and intended account privately. `default` and `p3-readonly` are reported to target the prior account. The author reports clearing the temporary credentials after the 2026-10-24 reads; before another authorized session, load MFA credentials as described in [NOTES.md](NOTES.md).
- **State:** keep backups outside Git. Do not replace, restore, or destroy state to diagnose the metadata difference.
- **Account-wide actions:** do not open or use the AWS Organizations console, create or join an Organization, or set up Control Tower. Pause before any other account-wide action. See the [credit safeguard](docs/decisions/terraform-bootstrap-s3-backend.md#account-wide-actions-and-credit-safeguard).
- **Public repository and project scope:** keep Phase 1 pull-request workflows build/test only, with no AWS access. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or its workflow logs. Do not derive the pipeline from the instructor’s `Jenkinsfile` without a focused need and approval, or reuse Project 1 or 2 resources without an approved design and verified ownership.
- Documentation updates do not authorize AWS changes, spending, deployment, apply, or unrelated Git operations. The author handles staging, commit, push, and merge for this documentation milestone after Codex confirms the review is complete; exclude unrelated changes.

## Next safe step

Continue Gate A preparation: finish the open paper checks, review the rule-tag statement's tag-key scope, and resolve `<ACCOUNT_ID>` and `<CANONICAL_ACCOUNT_ID>` only in private copies before presenting a separate approval request for any AWS session or policy attachment. The SSM parameter ARN account segment also remains unresolved. Keep NAT-only versus an S3 gateway endpoint undecided until its route and cost assumptions are reviewed. No AWS work, bucket use, root session, policy attachment, or Terraform is authorized by this documentation update. Network/compute implementation and Jenkins come later; old-account inventory and cleanup remain separately deferred.

**Future-session precondition:** the author reports signing out after session 2; that one-session authorization is complete and cannot be reused. Any later owner or AWS CLI activity needs separate authorization. Before a future separately authorized AWS CLI read or Terraform command, load credentials with `eval "$(aws configure export-credentials --profile p3-new --format env)"` (the CLI prompts for MFA), then run `aws sts get-caller-identity` in that same shell. Confirm `assumed-role/p3-terraform` and, privately, the intended account before continuing; the apply-session account ID was redacted, and the later account match is author-reported rather than independently verifiable here. Never rely on `default`; clear the exported credentials when finished. See [NOTES.md](NOTES.md) for the documented flow.

The exact OIDC `sub` was reported from temporary workflow run #1; the `aud` claim itself was not printed separately. The role-session-name match, `amazon.aws` version, SSM document and transfer behavior remain deployment-stage checks. Keep `<ACCOUNT_ID>` in repository files; only use substituted policy copies in a private location after the relevant approval.


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
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [ ] Deployment to the approved target and health behavior are verified.
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated; the forced CI error path turned CI red, but the original zero-test assertion and rollback behavior remain unverified.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean.

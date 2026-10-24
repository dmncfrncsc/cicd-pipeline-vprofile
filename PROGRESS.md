# Project 3 session handoff

**Updated 2026-10-24.** Concise handoff based on local repository files and dated author-supplied evidence. Live service state may have changed since the recorded checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase: durable-bucket Terraform code merged; apply not approved.** The author reports that owner session 1 created both named boundaries and attached `p3-terraform-durable` to `p3-terraform`; the author later reported signing out. Preparing the two-bucket code and plan was separately approved, and PR #66 is merged. Neither an apply nor spending is approved. See the [new-account design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence limits.

## Current state

- **Phase 1, GitHub Actions build/test (reported complete):** recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. The workflow has no AWS access and keeps the WAR on the runner. No later CI run or ruleset check is recorded. See the [workflow](.github/workflows/build-test.yml), [NOTES.md](NOTES.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **New-account bootstrap (reported, 2026-10-21):** the six-resource state-bucket bootstrap was applied and migrated to S3; a later plan reported `No changes`. These are dated terminal results, not a live check. See the [bootstrap backend decision](docs/decisions/terraform-bootstrap-s3-backend.md) for backend settings and the state-metadata question.
- **Read-only AWS preflight (author-supplied terminal output, 2026-10-23):** output reported `assumed-role/p3-terraform` and access to the recorded bootstrap state bucket and state-object metadata. The account ID was redacted; the object body and bucket settings were not read, so this did not confirm account alignment, state contents, or versioning. Full scope and limits are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Durable bucket Terraform (code merged, not applied):** PR #66 merged as `169aec1` and added `infra/durable/` for the WAR and Ansible-transfer buckets. Author-supplied WSL output reports `terraform fmt -check` exit 0, successful init with AWS provider `v6.70.0`, and a reviewed plan of 6 to add, 0 to change, 0 to destroy; filtered output showed the intended settings and no public-access-block or bucket-policy resources. The identity output was redacted, so account alignment is unconfirmed. No apply, bucket creation, or spending is reported. See the [design decision](docs/decisions/new-account-deployment-design.md) and [history](PROGRESS-HISTORY.md).
- **IAM documents:** the durable candidate and proposed networking/compute policies, including full JSON and measurements, are in [the assembled candidates](docs/drafts/new-account-assembled-iam-policy-candidates.md). The candidates are not confirmed copies of the saved AWS policies. The networking/compute managed-policy split is a proposal. See the [design decision](docs/decisions/new-account-deployment-design.md) for rationale.
- **Prior account:** paused; its bootstrap state and D1 buckets are recorded as implemented. Cleanup and the support case remain unresolved.
- **Instruction files:** The author confirmed on 2026-10-22 that Master Prompt v4.9 and Project Instructions v3.9 are the official Project 3 guidance. Their local files now identify them as adopted; the earlier screenshot showed their placement. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Decision and approval status

| Item | Status |
| --- | --- |
| Cost gate | Accepted on planning estimates (2026-10-22); the session-duration basis and other limitations remain open in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) |
| First Terraform change | Two durable buckets only; code and plan preparation were separately approved and merged. Apply and spending are not approved |
| Owner sessions | Session 1's IAM work and later sign-out are author-reported; session 2 still needs separate approval after bucket creation and before either bucket is used |
| IAM structure | Boundaries remain outside `p3-terraform` and Terraform and are not yet attached to project roles; networking/compute managed-policy split is only a proposal. Draft details and rationale are in the [design decision](docs/decisions/new-account-deployment-design.md) |
| Deployment IAM and SSM | GitHub Environment `production` on `main` and `aws_ssm` are review directions, not verified integration. OIDC subject suffix, SSM document/plugin behavior, provider calls, and effective permissions remain open |
| Jenkins | Required before completion; setup option remains undecided |

## Open risks and gaps

- **State metadata:** the 2026-10-22 check reported live S3 serial 1 and a different lineage from the preserved backup (serial 7). On 2026-10-23, `head-object` reported the same 9,174-byte size as the pre-migration backups, but that metadata match does not establish matching contents; the object body was not read and the cause of the serial/lineage difference is unknown.
- **Bootstrap IAM and S3 settings:** `s3:PutBucketPublicAccessBlock` on the bootstrap role is a separate, unaccepted issue. Account-level S3 settings are unchecked; do not rely on them as a backstop.
- **IAM review:** the local candidates are not confirmed copies of the AWS policies or proof of effective permissions. Review line-by-line content before relying on them. The complete JSON and measurements are in [the assembled candidates](docs/drafts/new-account-assembled-iam-policy-candidates.md); unresolved IAM, provider, and quota checks are tracked in the [design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **SonarCloud findings (author-reported, PR #66):** two `terraform:S6258` access-logging findings and two `terraform:S6249` HTTPS-only findings were Accepted. The author also reports that the resulting Quality Gate passed; the screenshot supporting that result was not available for independent inspection here. Accepted findings are not fixes. The `S6249` acceptance depends on the separately approved owner session applying and reading back HTTPS-only policies before either bucket is used.
- **Transfer-bucket retention (planning decision, 2026-10-23):** the Ansible transfer bucket is planned unversioned because deploy permission policy v1 lacks `s3:DeleteObjectVersion`. Durable Terraform must not enable versioning, and the setting must be read back after creation. No AWS bucket setting was checked. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).
- **Costs and credits:** the cost gate was accepted on dated estimates, not a quote. Its accepted session-duration basis is unconfirmed: the design record labels 8 hours as an assumption, while the history comparison shows illustrative 48-hour and 730-hour cases. Regional pricing and workload limits remain open; charges and this account’s credit eligibility are unknown, and no monthly budget exists. Prior-account credits expired after an Organization was created. Do not infer that this account has the same eligibility or credit outcome.

## Safety boundaries

- **Terraform identity:** use WSL. Author-supplied terminal output dated 2026-10-22 records `p3-new` assuming `p3-terraform`; before every Terraform command, run `aws sts get-caller-identity` in that same shell and confirm both `assumed-role/p3-terraform` and, privately, the intended account. The 2026-10-23 preflight output had its account ID redacted, so it did not establish the account match in this public record. `default` and `p3-readonly` are reported to target the prior account. Before reusing the shell, clear exported credentials with `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION`. See the MFA procedure in [NOTES.md](NOTES.md).
- **State:** keep backups outside Git. Do not replace, restore, or destroy state to diagnose the metadata difference.
- **Account-wide actions:** do not open or use the AWS Organizations console, create or join an Organization, or set up Control Tower. Pause before any other account-wide action. See the [credit safeguard](docs/decisions/terraform-bootstrap-s3-backend.md#account-wide-actions-and-credit-safeguard).
- **Public repository and project scope:** keep Phase 1 pull-request workflows build/test only, with no AWS access. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or its workflow logs. Do not derive the pipeline from the instructor’s `Jenkinsfile` without a focused need and approval, or reuse Project 1 or 2 resources without an approved design and verified ownership.
- Documentation updates do not authorize AWS changes, spending, deployment, apply, or unrelated Git operations. The author handles staging, commit, push, and merge for this documentation milestone after Codex confirms the review is complete; exclude unrelated changes.

## Next safe step

No AWS command is currently approved. The earlier code-and-plan approval has been used. If you want to continue, first authorize a fresh WSL identity check and read-only plan review; verify `assumed-role/p3-terraform` and privately confirm the intended account in that same shell, then regenerate and inspect the plan. After reviewing the exact proposed changes and cost, decide separately whether to approve the apply. Do not reuse the earlier saved plan as standing authorization. After bucket creation, session 2 still needs its own approval to apply and read back each HTTPS-only policy and the bucket security settings before either bucket is used. Deployment IAM/SSM integration and Jenkins come later; prior-account approvals do not carry over.

**Session-start precondition:** in WSL, first load temporary credentials with `eval "$(aws configure export-credentials --profile p3-new --format env)"` (the CLI prompts for MFA). Then run `aws sts get-caller-identity` in that same shell and confirm `assumed-role/p3-terraform` and, privately, the intended account before any other AWS CLI read or Terraform command. Never rely on `default`; clear the exported credentials when finished. See [NOTES.md](NOTES.md) for the tested flow.

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

# Project 3 session handoff

**Updated 2026-10-23.** Concise handoff based on local repository files and dated author-supplied evidence. Live service state may have changed since the recorded checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase: first-step readiness.** The review-only IAM candidates are assembled and measured, and two review-only HTTPS bucket-policy drafts are now saved in the [IAM package](docs/drafts/new-account-iam-policy-package.md). The separately authorized read-only AWS preflight was reported complete on 2026-10-23; it did not read state contents or check bucket settings. The author has chosen the timing and scope of the initial owner setup, but its checklist remains a proposal. The first bucket-only Terraform code and plan do not exist. On 2026-10-22, the author accepted the cost gate using existing planning estimates; regional-rate, credit, budget, and technical limits remain open. Implementation, root sign-in, AWS changes, and spending are not approved. See the [new-account design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Current state

- **Phase 1, GitHub Actions build/test (reported complete):** recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. The workflow has no AWS access and keeps the WAR on the runner. No later CI run or ruleset check is recorded. See the [workflow](.github/workflows/build-test.yml), [NOTES.md](NOTES.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **New-account bootstrap (reported, 2026-10-21):** the six-resource state-bucket bootstrap was applied and migrated to S3; a later plan reported `No changes`. These are dated terminal results, not a live check. See the [bootstrap backend decision](docs/decisions/terraform-bootstrap-s3-backend.md) for backend settings and the state-metadata question.
- **Read-only AWS preflight (author-supplied terminal output, 2026-10-23):** the session reported `assumed-role/p3-terraform`; the account ID was redacted, so this output alone does not establish that it was the intended new account. `head-bucket` succeeded for the recorded bootstrap state bucket in `us-east-1`, and `head-object` found `bootstrap/terraform.tfstate` (9,174 bytes, SSE-S3, with a VersionId). The object body and bucket settings were not read. Versioning is not confirmed by a bucket-settings read. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for scope and limits.
- **Latest documentation sync (PR #61, author-reported merged; local HEAD verified 2026-10-23):** the supplied GitHub screenshot shows “docs: record Project 3 preflight and next steps” merged as `dc17d0b`, with 2 checks passed and a SonarQube Cloud Quality Gate passed (0 new issues, 0 accepted issues, 0 security hotspots; 0.0% coverage and duplication on new code). Check names are not visible. Supplied terminal output records `main` fast-forwarding from `83cd2bf` to `dc17d0b`, deletion of the finished branch and stale remote-tracking ref, and an empty status output. This checkout is on `main` at `dc17d0b` (`origin/main` is the local tracking ref); this session cannot inspect the `vprofile-src` submodule status because its Git metadata is inaccessible. Earlier documentation syncs are recorded in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Not recorded in the new account:** application stack, WAR bucket, Ansible transfer bucket, deployment, health check, or rollback.
- **Prior account:** paused; its bootstrap state and D1 buckets are recorded as implemented. Cleanup and the support case remain unresolved.
- **Instruction files:** The author confirmed on 2026-10-22 that Master Prompt v4.9 and Project Instructions v3.9 are the official Project 3 guidance. Their local files now identify them as adopted; the earlier screenshot showed their placement. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Pending approvals and decisions

| Item | Status |
| --- | --- |
| Cost gate | Accepted on existing planning estimates (2026-10-22); accepted session-duration basis is unconfirmed, and other limits remain open in PROGRESS-HISTORY.md |
| Implementation, spending, and AWS changes | Not approved |
| Root console session | Not approved. Root is reported as the only existing admin path; sign-in availability is reported but untested |
| Boundary ownership | Option B chosen (2026-10-22): the boundaries stay outside `p3-terraform` and Terraform and require a separately approved owner session. Planning only |
| Boundary timing | Initial-setup timing chosen on 2026-10-23 (option A): create both boundaries in the first owner session, before the later role-creation stage. Exact names must match the durable draft. No session is approved |
| First-session Terraform permissions | Durable inline policy only; networking and compute policy drafts are deferred until the ephemeral stage. This is the author's accepted planning choice, not implementation approval |
| Owner-session checklist | Drafted as a proposal; it is not finalized or adopted |
| Account-ID substitution | Keep `<ACCOUNT_ID>` in Git; prepare copies under the WSL home folder `~/p3-owner-session/`. The extraction was not confirmed as run, and its old fixed line range is stale after this update |
| `p3-terraform` role-policy/trust scope | Option 2 chosen as the working choice for review (2026-10-23): an explicit deny of `iam:UpdateAssumeRolePolicy` and `iam:DeleteRole` on `p3-vprofile-deploy`, placed in the root-attached durable policy; the instance role stays under Terraform (risk accepted as part of option 2 as described). Planning only; not approved for implementation. Caveats in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) |
| Deploy-role GitHub trust design | GitHub Environment `production` restricted to `main` chosen for review (2026-10-23); trust checks audience, environment subject, `ref`, `environment`, repository ID and owner ID. Author-supplied read-only GitHub API output confirms the drafted immutable repository prefix; the `:environment:production` suffix still needs a real workflow claim. Draft remains review-only |
| Ansible connection method | `aws_ssm` plugin from the GitHub runner is the working assumption (2026-10-23); not verified. The plugin's default session document is not documented (see the 2026-10-23 source check in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md)) |
| Jenkins J1 vs. J2 | Undecided; Jenkins is required before project completion |
| HTTPS-only bucket-policy exposure | Bootstrap state-bucket risk temporarily accepted (2026-10-22). For the two durable buckets, `p3-terraform` gets no bucket-policy write access; the owner applies the saved review-only policies after bucket creation and before use. Not AWS-validated or applied |

## Open risks and gaps

- **State metadata:** the 2026-10-22 check reported live S3 serial 1 and a different lineage from the preserved backup (serial 7). On 2026-10-23, `head-object` reported the same 9,174-byte size as the pre-migration backups, but that metadata match does not establish matching contents; the object body was not read and the cause of the serial/lineage difference is unknown.
- **Bootstrap IAM and S3 settings:** `s3:PutBucketPublicAccessBlock` on the bootstrap role is a separate, unaccepted issue. Account-level S3 settings are unchecked; do not rely on them as a backstop.
- **New-account IAM review-only candidates:** complete assembled JSON is saved in [the policy candidates file](docs/drafts/new-account-assembled-iam-policy-candidates.md): durable inline policy, 17 statements/4,970 characters; networking proposal, 10/4,295; compute proposal, 7/2,084. The measured aggregate inline-policy text is 6,450 characters including the existing `p3-state-bucket` policy (1,480); these are size and JSON-structure checks, not AWS IAM validation or proof of effective permissions. The original reported 14-statement policy was not recovered; the durable candidate uses the separate option-B reconstruction. The networking/compute split remains a proposal. Account-specific Service Quotas, S3 state/lock action support, Terraform provider calls/tag timing, `iam:PassRole` provider behavior, and the default EBS key remain unresolved. See the [IAM package](docs/drafts/new-account-iam-policy-package.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Transfer-bucket retention (planning decision, 2026-10-23):** the Ansible transfer bucket is planned unversioned because deploy permission policy v1 lacks `s3:DeleteObjectVersion`. Durable Terraform must not enable versioning, and the setting must be read back after creation. No AWS bucket setting was checked. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).
- **Costs and credits:** the cost gate was accepted on dated estimates, not a quote. Its accepted session-duration basis is unconfirmed: the design record labels 8 hours as an assumption, while the history comparison shows illustrative 48-hour and 730-hour cases. Regional pricing and workload limits remain open; charges and this account’s credit eligibility are unknown, and no monthly budget exists. Prior-account credits expired after an Organization was created. Do not infer that this account has the same eligibility or credit outcome.

## Safety boundaries

- **Terraform identity:** use WSL. Author-supplied terminal output dated 2026-10-22 records `p3-new` assuming `p3-terraform`; before every Terraform command, run `aws sts get-caller-identity` in that same shell and confirm both `assumed-role/p3-terraform` and, privately, the intended account. The 2026-10-23 preflight output had its account ID redacted, so it did not establish the account match in this public record. `default` and `p3-readonly` are reported to target the prior account. Before reusing the shell, clear exported credentials with `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION`. See the MFA procedure in [NOTES.md](NOTES.md).
- **State:** keep backups outside Git. Do not replace, restore, or destroy state to diagnose the metadata difference.
- **Account-wide actions:** do not open or use the AWS Organizations console, create or join an Organization, or set up Control Tower. Pause before any other account-wide action. See the [credit safeguard](docs/decisions/terraform-bootstrap-s3-backend.md#account-wide-actions-and-credit-safeguard).
- **Public repository and project scope:** keep Phase 1 pull-request workflows build/test only, with no AWS access. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or its workflow logs. Do not derive the pipeline from the instructor’s `Jenkinsfile` without a focused need and approval, or reuse Project 1 or 2 resources without an approved design and verified ownership.
- Documentation updates do not authorize AWS changes, spending, deployment, implementation, or unrelated Git operations. The author handles staging, commit, push, and merge for this milestone after Codex confirms the documentation review is complete and the diff is clean; exclude unrelated changes.

## Planned sequence

The cost gate is accepted on planning estimates. The bounded identity and bootstrap-state preflight was reported complete on 2026-10-23. The author adopted a staged first step: initial owner setup, a Terraform change limited to the two durable buckets, owner-applied HTTPS-only policies and read-backs before use, then later owner-led teardown. Defer deploy-role and Ansible integration checks until the deployment stage. Seek separate approval before implementation or spending. Jenkins remains a required later phase. Prior-account Phase D approvals do not carry over.

## Next safe step

Decided 2026-10-23 (planning only, nothing applied): transfer bucket unversioned; `s3:GetBucketLocation` removed from the transfer-bucket statement only; owner-managed HTTPS-only policies planned for both durable buckets; SSE-S3 for both; ephemeral state key `ephemeral/terraform.tfstate`; and `p3-terraform` trust reviewed with no change identified. The author chose to create both externally managed boundaries in the initial owner session and attach only the durable inline policy to `p3-terraform`; networking and compute permissions wait until the ephemeral stage. The account-ID placeholder stays in Git, with substituted copies planned outside the repository. The review-only HTTPS policies are saved in the [IAM package](docs/drafts/new-account-iam-policy-package.md). The owner-session checklist remains a proposal. See the [new-account design decision](docs/decisions/new-account-deployment-design.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

**Session-start precondition:** use WSL and the recorded `p3-new` MFA flow. Start the shell by running `aws sts get-caller-identity`; confirm it reports `assumed-role/p3-terraform` before any other AWS CLI read or Terraform command. Never rely on `default`.

**Next:** confirm whether the local template-extraction step ran. The conversation does not include its output, and its `sed -n '842,913p'` range is now stale because this update added text above the boundary section. If it did not run, regenerate the read-only extraction against the current headings and run it in WSL, keeping substituted copies under `~/p3-owner-session/` outside the repository; report only counts, not policy contents or account IDs. Then finalize and review the proposed owner-session checklist against the saved policies, exact boundary names, and read-back criteria. The read-backs are a reviewed policy attached to each bucket, all four Block Public Access settings enabled on both, SSE-S3 on both, and transfer-bucket versioning off; they do not include a real HTTP behavior test. Seek separate approval before writing the first Terraform code, limited to the two durable buckets. Keep the policy package review-only. Defer the GitHub Environment suffix, role-session-name match, `amazon.aws` pin, plugin document, and transfer-path checks until deployment integration. No root session, AWS change, implementation, or spending is approved.


## References

- [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md): milestones and dated evidence
- [NOTES.md](NOTES.md): technical learning reference
- [README.md](README.md): repository overview
- [Decision records](docs/decisions/): [bootstrap backend](docs/decisions/terraform-bootstrap-s3-backend.md) and [new-account design](docs/decisions/new-account-deployment-design.md)
- Claude Project Knowledge copies of PROGRESS.md and PROGRESS-HISTORY.md predate the 2026-10-23 updates; refresh them only with separate explicit authorization.

Defer the interview guide until implementation is sufficiently complete and verified. A later guide should separate tutorial-provided, pre-existing, generated, and AI-assisted work from verified author contributions.

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

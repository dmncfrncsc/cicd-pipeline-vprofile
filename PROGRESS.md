# Project 3 session handoff

**Updated 2026-10-23.** Concise handoff based on local repository files and dated author-supplied evidence. Live service state may have changed since the recorded checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase: new-account durable IAM design review (planning).** On 2026-10-22, the author accepted the cost gate using the existing planning estimates; regional-rate, credit, budget, and technical limits remain open. Implementation is not approved. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).

## Current state

- **Phase 1, GitHub Actions build/test (reported complete):** recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. The workflow has no AWS access and keeps the WAR on the runner. No later CI run or ruleset check is recorded. See the [workflow](.github/workflows/build-test.yml), [NOTES.md](NOTES.md), and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **New-account bootstrap (reported, 2026-10-21):** the six-resource state-bucket bootstrap was applied and migrated to S3; a later plan reported `No changes`. These are dated terminal results, not a live check. See the [bootstrap backend decision](docs/decisions/terraform-bootstrap-s3-backend.md) for backend settings and the state-metadata question.
- **Documentation PR #51 (reported merge; local state checked 2026-10-23):** local Git history contains merge commit `d6d39a3` on `main` (commit metadata dated 2026-10-22). Author-supplied terminal output records the local fast-forward and cleanup of the finished branch and stale tracking ref. This does not establish current GitHub status or PR check results; see [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- **Not recorded in the new account:** application stack, WAR bucket, Ansible transfer bucket, deployment, health check, or rollback.
- **Prior account:** paused; its bootstrap state and D1 buckets are recorded as implemented. Cleanup and the support case remain unresolved.
- **Instruction files:** The author confirmed on 2026-10-22 that Master Prompt v4.9 and Project Instructions v3.9 are the official Project 3 guidance. Their local files now identify them as adopted; the earlier screenshot showed their placement. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).

## Pending approvals and decisions

| Item | Status |
| --- | --- |
| Cost gate | Accepted on existing planning estimates (2026-10-22); accepted session-duration basis is unconfirmed, and other limits remain open in PROGRESS-HISTORY.md |
| Implementation, spending, and AWS changes | Not approved |
| Root console session | Not approved; root is reported as the only existing admin path and is planned to create the boundaries and attach the reviewed durable policy under option B |
| Boundary ownership | Option B chosen (2026-10-22): `p3-terraform` will not create or edit the boundaries; a separately approved root session is planned. Planning only |
| `p3-terraform` role-policy/trust scope | Option 2 chosen as the working choice for review (2026-10-23): an explicit deny of `iam:UpdateAssumeRolePolicy` and `iam:DeleteRole` on `p3-vprofile-deploy`, placed in the root-attached durable policy; the instance role stays under Terraform (risk accepted as part of option 2 as described). Planning only; not approved for implementation. Caveats in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) |
| Deploy-role GitHub trust design | GitHub Environment `production` restricted to `main` chosen for review (2026-10-23); trust checks audience, environment subject, `ref`, `environment`, repository ID and owner ID. Draft is review-only; the environment `sub` string is unverified |
| Ansible connection method | `aws_ssm` plugin from the GitHub runner is the working assumption (2026-10-23); not verified, and the session document it uses is unconfirmed |
| Jenkins J1 vs. J2 | Undecided; Jenkins is required before project completion |
| HTTPS-only bucket-policy exposure | Bootstrap state-bucket risk temporarily accepted; acceptance for the two durable buckets is not recorded and remains undecided |

## Open risks and gaps

- **State metadata (2026-10-22):** live S3 showed serial 1 and a different lineage from the preserved backup (serial 7). Contents were not compared; the cause is unknown.
- **Bootstrap IAM and S3 settings:** `s3:PutBucketPublicAccessBlock` on the bootstrap role is a separate, unaccepted issue. Account-level S3 settings are unchecked; do not rely on them as a backstop.
- **New-account IAM package:** the original final 14-statement JSON was not recovered. The review-only package preserves the 15-statement reconstruction, the earlier boundary drafts marked superseded, and a separate 14-statement option-B reconstruction, plus review-only drafts added 2026-10-23 (deploy trust, deploy permission v1, instance trust, instance permission v2, a deploy-role deny statement, and both redrafted boundaries); none is active or applied. Option 2 is the working choice for the `p3-terraform` scope (review only). The instance boundary matches SSM agent permission policy v2 and excludes `ssm:GetParameter(s)`; the deploy boundary exactly copies deploy permission policy v1 (8 statements). See the [redrafted boundaries](docs/drafts/new-account-iam-policy-package.md#2026-10-23-redrafted-permissions-boundaries-review-only-planning). Current `amazon.aws.aws_ssm` documentation says the controller uses presigned S3 URLs and the managed instance needs no S3 IAM credentials for that documented path; the project’s selected version/configuration and deployment remain unverified. The ephemeral layer must tag the instance `Project=p3-vprofile`; the exact GitHub session-name match, session-document existence/use, and managed-policy size limit remain unverified. The deploy-role trust must exclude pull-request workflows; its drafted environment `sub` string and effective permissions remain unverified. Other open items: encryption mode, `p3-terraform` trust/MFA condition, ephemeral policy/state key, durable-bucket `s3:PutBucketPolicy` exposure, possible missing IAM read/tag actions from the five-statement review, and the aggregate inline-policy size (estimated about 6,101 compact characters against an unverified limit). See the [IAM draft package](docs/drafts/new-account-iam-policy-package.md) and the [new-account design decision](docs/decisions/new-account-deployment-design.md).
- **Costs and credits:** the cost gate was accepted on dated estimates, not a quote. Its accepted session-duration basis is unconfirmed: the design record labels 8 hours as an assumption, while the history comparison shows illustrative 48-hour and 730-hour cases. Regional pricing and workload limits remain open; charges and this account’s credit eligibility are unknown, and no monthly budget exists. Prior-account credits expired after an Organization was created. Do not infer that this account has the same eligibility or credit outcome.

## Safety boundaries

- **Terraform identity:** use WSL. Author-supplied terminal output dated 2026-10-22 records `p3-new` assuming `p3-terraform`; before every Terraform command, run `aws sts get-caller-identity` in that same shell and confirm `assumed-role/p3-terraform`. `default` and `p3-readonly` are reported to target the prior account. Before reusing the shell, clear exported credentials with `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_CREDENTIAL_EXPIRATION`. See the MFA procedure in [NOTES.md](NOTES.md).
- **State:** keep backups outside Git. Do not replace, restore, or destroy state to diagnose the metadata difference.
- **Account-wide actions:** do not open or use the AWS Organizations console, create or join an Organization, or set up Control Tower. Pause before any other account-wide action. See the [credit safeguard](docs/decisions/terraform-bootstrap-s3-backend.md#account-wide-actions-and-credit-safeguard).
- **Public repository and project scope:** keep Phase 1 pull-request workflows build/test only, with no AWS access. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or its workflow logs. Do not derive the pipeline from the instructor’s `Jenkinsfile` without a focused need and approval, or reuse Project 1 or 2 resources without an approved design and verified ownership.
- Documentation updates do not authorize AWS changes, spending, deployment, implementation, or unrelated Git operations. The author handles staging, commit, push, and merge for this milestone after Codex confirms the documentation review is complete and the diff is clean; exclude unrelated changes.

## Planned sequence

The cost gate is accepted. Complete the durable and ephemeral IAM/design review, then seek separate implementation approval; deployment may proceed only after that approval. Jenkins follows as a required later phase. Prior-account Phase D approvals do not carry over.

## Next safe step

The aggregate inline-policy size recheck (estimated about 6,101 compact characters against an unverified 10,240 limit) and the review of the five durable-policy statements were completed on 2026-10-23 (review-only; see PROGRESS-HISTORY.md). Resolve the remaining open IAM items listed above and confirm the environment `sub` string before any first apply. Option 2 is the working choice for review only. Keep the package review-only. No root session, AWS check or change, implementation, or spending is approved. See the [new-account design decision](docs/decisions/new-account-deployment-design.md).


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

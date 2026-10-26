# Project 3 session handoff

**Updated 2026-10-26.** This handoff combines local Git state and the supplied continuation transcript; AWS and GitHub were not checked live. The transcript reports one successful end-to-end GitHub Actions deployment to an ephemeral instance, followed by teardown and empty resource checks. Jenkins, rollback, and live billing/credit status remain open. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limitations.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** complete the deploy-role SSM permission repair, then verify rollback. The prior test stopped before app deployment; see Current status and Next safe step below.

## Current status

**Repository:** Local `main` matched `origin/main` at `8230685` after PR #98 and was clean before this update. Local Git status was checked; AWS and GitHub services were not checked live.

**Deployment:** Phase 1 build/test has recorded successful runs. Deploy #5 on `4d8c178` was reported green, followed by ephemeral teardown. This does not verify rollback, login, a real user session, or search behavior.

**Rollback attempt:** PR #94 added Ansible backup/rescue, PR #95 added the default-off `force_failure` switch, and PR #96 added post-rollback `/users` and database checks. The later test created a 14-resource stack, but Deploy 1 failed at `ssm:TerminateSession` before deploying the app; rollback did not run. PR #97 changed the repository policy pattern to `session/p3-deploy-*`. A saved plan reported only `aws_iam_role_policy.deploy` changing in place (0 add, 1 change, 0 destroy), but the transcript does not show its apply, saved-policy read-back, or matching deploy-boundary update. The stack was reported torn down with empty state/resource checks in `us-east-1`; billing and credits were not checked.

**Open follow-up:** The failed public Actions log reportedly contained the AWS account ID; its deletion is unconfirmed. No credential exposure was reported. The repository-side policy fix and the matching deploy boundary are not confirmed live. `ec2:DisassociateAddress` was denied during teardown; a refreshed EIP-only destroy succeeded, but the permission gap remains. Jenkins is required and J1/J2 is undecided. Source-use permission remains unresolved.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

If the failed public Actions run still exists, delete it before another deployment. Then resume the approved permission repair in WSL: load the documented `p3-new` MFA session, confirm `assumed-role/p3-terraform` and the intended account privately in the same shell, and review/apply only the deploy-role inline-policy update. The transcript's saved plan showed one in-place change, but no apply or read-back. If that saved plan is unavailable or stale, create and review a fresh plan first. In the bounded owner session, update and read back the deploy boundary to match `session/p3-deploy-*` and add/read back `ec2:DisassociateAddress` in `p3-terraform-networking`; completion is not reported. Before recreating the stack, confirm the authorization covers the retry after these permission changes. A fresh-host rollback test needs three deploys: normal install, normal redeploy to create the backup, then forced failure. Tear down afterward and verify resources and credentials. Jenkins follows rollback verification.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. Clear/count AWS variables after the session; the transcript's zero count applied before a later MFA session was loaded.
- Keep account IDs, credentials, VProfile source, and WAR contents out of the public repository and workflow logs. Public pull-request workflows stay build/test only. Do not use the instructor's `Jenkinsfile` without a focused need and approval, or reuse other projects' resources without an approved design and verified ownership.
- Do not use AWS Organizations or set up Control Tower; pause before other account-wide actions. Keep Terraform state backups outside Git and do not alter state to investigate the metadata mismatch.
- Documentation edits do not authorize AWS changes, spending, deployments, or Git operations. The author handles staging, commits, pushes, merges, and cleanup.
## Working agreement

- Check only new questions; do not repeat reviews of unchanged drafts.
- Accept small, recoverable risks and fix ordinary failures as they arise; stop for risks that could expose credentials or require an owner session.
- Combine dependent steps when safe, and document material checkpoints rather than every decision.
- Choose established practices sized to this single-user project's learning goals, scope, and cost limits. Do not add external services known to impose new token-expiry mechanisms; existing MFA and GitHub OIDC sessions still expire by design.
- These principles do not waive approvals for AWS changes, billable work, workflow runs, permission changes, or owner sessions, and do not waive the same-shell identity check.

OIDC claim limits, the unpinned Session Manager plugin URL, and Canonical public-parameter source findings are detailed in [NOTES.md](NOTES.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md). AWS documentation supports an empty account segment in public Parameter Store ARNs; availability of the exact Canonical parameter in `us-east-1` remains unchecked.


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
- [ ] Deployment to the approved target and health behavior are verified (one GitHub Actions run is reported successful; primary run evidence was not independently reviewed in this update).
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated; the CI error path turned CI red, and rollback code is merged but the rollback path has not run.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean.

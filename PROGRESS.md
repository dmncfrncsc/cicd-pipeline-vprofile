# Project 3 session handoff

**Updated 2026-10-26.** This handoff combines local Git state and the supplied continuation transcript; AWS and GitHub were not checked live. Deploy #5 was reported successful and followed by teardown. The first rollback-test deploy stopped before the app, so rollback remains untested. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** obtain separate approval for the reviewed PR #97 policy plan, then validate deployment and rollback. The plan has not been applied.

## Current status

**Repository:** Local Git shows `main` and `origin/main` at `7acc854` (PR #100 merge). Top-level status was clean with the inaccessible submodule ignored; its status was not checked. No live GitHub check was made.

**Deployment:** Deploy #5 on `4d8c178` was reported green and followed by teardown. The later Deploy 1 failed at `ssm:TerminateSession` before the app, so rollback did not run. Login, a real user session, and search behavior remain unverified.

**IAM repair and plan (author-reported):** The owner session ended with root sign-out. `p3-terraform-networking` is reported at Version 3, default and attached to `p3-terraform`; the saved-statement read-back showed `ec2:DisassociateAddress` once and `network-interface/*` as the eighth resource. The `p3-vprofile-deploy` role page was reported to show its boundary set. An earlier read-back reported boundary Version 2 as default; the latest screenshot did not show its default version. In WSL, the author reports `p3-new`, `assumed-role/p3-terraform`, and a private account match in the same shell. The saved `deploy-policy.tfplan` from `7acc854` reported 0 add, 1 change, 0 destroy; its reviewed diff changes only the `Resource` value in `aws_iam_role_policy.deploy` to `session/p3-deploy-*`. It has not been applied; the initial role/policy creation was reported separately.

**Open follow-up:** The NAT network-interface `Project=p3-vprofile` tag condition is untested, so the next teardown may still deny disassociation. Checking runs #1–#3 for account-ID output is low priority; Deploy #6 deletion was reported. Jenkins/J1-vs-J2, billing/credits, and source-use permission remain open. The latest WSL report shows temporary AWS credentials loaded; no subsequent unset was reported.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

The reviewed `deploy-policy.tfplan` has not been applied because separate approval is still required. Before applying, confirm approval, recheck `assumed-role/p3-terraform` and the account in the same WSL shell, and ensure the saved plan still matches the current state; if it may be stale, create and review a fresh plan first. If stopping before apply, clear the exported AWS variables as described in [NOTES.md](NOTES.md). After the permission update, review authorization for another deployment, then run the three-dispatch rollback sequence on a fresh host and verify teardown. Jenkins follows rollback verification.

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

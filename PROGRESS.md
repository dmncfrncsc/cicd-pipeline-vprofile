# Project 3 session handoff

**Updated 2026-10-26.** This handoff combines local Git state and the supplied continuation transcript; AWS and GitHub were not checked live. Deploy #5 was reported successful on an ephemeral instance and followed by teardown; the later rollback attempt stopped before deploying the app. Jenkins, rollback, and live billing/credit status remain open. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limitations.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** finish the approved IAM permission repair, then retry the deployment and verify rollback. The prior test stopped before app deployment; see Current status and Next safe step below.

## Current status

**Repository:** Local Git shows `main` and `origin/main` at `8fa00de`, the PR #99 merge. The worktree was clean when checked with the submodule ignored, before these documentation edits. AWS and GitHub services were not checked live.

**Deployment:** Phase 1 build/test has recorded successful runs. Deploy #5 on `4d8c178` was reported green, followed by ephemeral teardown. This does not verify rollback, login, a real user session, or search behavior.

**Rollback attempt and permission repair:** PRs #94–#96 added the rollback path and checks. Deploy 1 failed at `ssm:TerminateSession` before deploying the app, so rollback did not run. PR #97 changed the repository policy pattern to `session/p3-deploy-*`. In the supplied continuation, the author reports saving version 2 of `p3-vprofile-deploy-boundary` as default, reading back an 8-statement policy and the matching `OwnSessionsOnly` resource. This was a selected read-back, not a full JSON comparison or attachment check. The later PR #97 follow-up plan for `aws_iam_role_policy.deploy` has not been reported applied; the earlier role and policy creation was reported separately. The private networking-policy copy was updated to add `ec2:DisassociateAddress` and a network-interface resource, but its console save and read-back are still pending. Whether the NAT network interface has the required `Project=p3-vprofile` tag is untested, so the resource-tag condition may still block disassociation. The stack was reported torn down with empty state/resource checks in `us-east-1`; billing and credits were not checked.

**Open follow-up:** The transcript reports that failed Deploy #6 was deleted; checking runs #1–#3 for account-ID output remains a low-priority follow-up. No credential exposure was reported. The boundary resource pattern is reported corrected in the console, but its attachment and full saved JSON have not been checked. `ec2:DisassociateAddress` was denied during teardown; the local private policy copy has been edited, but the console update is incomplete. Jenkins is required and J1/J2 is undecided. Source-use permission remains unresolved.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

Finish the active approved owner session in the IAM console. The boundary update is reported saved; read back both policies, confirm `p3-terraform-networking` includes `ec2:DisassociateAddress` and the network-interface resource and remains attached to `p3-terraform`, and confirm `p3-vprofile-deploy-boundary` remains set on `p3-vprofile-deploy`. Then sign out. The networking-policy console save, association checks, and sign-out are not yet reported. The private networking file's local checks do not establish the saved AWS policy.

After the owner session, load the documented `p3-new` MFA session in WSL and privately verify `assumed-role/p3-terraform` and the intended account in the same shell. Make and review a fresh plan for the PR #97 deploy-role inline-policy update; the earlier plan may be stale. Applying it needs its own approval. Before another deployment, review the retry authorization. A fresh-host rollback test needs three deploys: normal install, normal redeploy to create the backup, then forced failure. Tear down afterward and verify resources and credentials. Jenkins follows rollback verification.

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

# Project 3 session handoff

**Updated 2026-10-26.** Local Git is at PR #103 merge `5b4a6d8`. The supplied conversation reports the `/users` retry fix merged and passed YAML parsing and an Ansible syntax check; it has not run on a host. The IAM correction is still unverified by a successful SSM session, and rollback remains untested. No live AWS or GitHub service was checked for this update. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** complete authorization review for the proposed three-dispatch rollback run. The one-run planning estimate was accepted with an 8-hour proposed limit; that acceptance does not authorize provisioning or a workflow run.

## Current status

**Repository:** Local Git shows `main`, `origin/main`, and `HEAD` at `5b4a6d8` (PR #103 merge). This documentation update leaves five files modified and unstaged, with no staged or untracked files; the submodule is excluded and its status was not checked. The supplied conversation reports that the PR checks passed and the topic branch was deleted. No live GitHub check was made.

**Deployment:** Deploy #5 on `4d8c178` was reported green and followed by teardown. The later Deploy 1 failed at `ssm:TerminateSession` before the app, so rollback did not run. PR #103 added `register: users_check` and `until: users_check.status in [200, 302]` to the Layer 3 `/users` request, alongside 3 retries and a 10-second delay. The supplied WSL output reports YAML parsing and `ansible-playbook --syntax-check` passed with Ansible Core 2.21.4; the fix has not been tested on a host. Login, a real user session, and search behavior remain unverified.

**IAM repair and plan (author-reported):** The owner session ended with root sign-out. `p3-terraform-networking` is reported at Version 3, default and attached to `p3-terraform`; a selected read-back showed `ec2:DisassociateAddress` and the network-interface resource. The deploy role's boundary was reported set, but its current default version is unknown. A fresh `p3-new` MFA session produced an ARN ending `assumed-role/p3-terraform`; this conversation does not record a private account match after that reload. The saved `deploy-policy.tfplan` reported 0 additions, 1 change, 0 destroys and changed the `Resource` value in `aws_iam_role_policy.deploy` to `session/p3-deploy-*`. The author reports approving and applying it; Terraform reported 0 added, 1 changed, 0 destroyed. A later `terraform plan` reported no changes. This does not verify a successful SSM session or rollback.

**Open follow-up:** The NAT network-interface `Project=p3-vprofile` tag condition is untested, so teardown may still need recovery. Checking runs #1–#3 for account-ID output is low priority; Deploy #6 deletion was reported. Jenkins/J1-vs-J2, billing/credits, and source-use permission remain open. The latest WSL transcript reports clearing exported AWS variables with a final count of 0; this is shell-scoped, not a live credential check. The `ansible/deploy.yml` header still says “draft, not yet run” although Deploy #5 was reported; that comment was identified as a separate code cleanup and was not changed in PR #103.

**Rollback cost review (author-accepted estimate):** The author accepted the existing planning estimate for one proposed run with an 8-hour time limit. This is not current pricing, a guaranteed dollar cap, or authorization to provision or dispatch. Credit coverage, the N. Virginia NAT rate, and package-site connectivity remain unknown.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

Finish the authorization review by deciding who will monitor the proposed 8-hour window and whether the three dispatches will run in one sitting or separate sittings. Confirm the proposed normal/forced-failure/normal order and record one Git ref/commit for all dispatches; the workflow does not pin a build ID. This plan is not run authorization. Before any Terraform command, use a fresh `p3-new` session in the same WSL shell and verify the role and intended account privately. Separate approval is required before provisioning and workflow dispatch. If later authorized, check actual remaining resources after teardown; the time limit alone cannot stop billing. Jenkins follows successful rollback verification.

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
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated; rollback code and the PR #103 `/users` retry fix are merged, but the rollback path has not run and the retry has only syntax-check evidence.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean (the post-PR #103 checkout was reported clean; this documentation update is currently unstaged).

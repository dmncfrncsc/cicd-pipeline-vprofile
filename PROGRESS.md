# Project 3 session handoff

**Updated 2026-10-28.** Local read-only inspection shows `main`, `origin/main`, and `HEAD` at `ba791f1`; `git status --short --branch --ignore-submodules=all` was clean before this documentation update. The supplied continuation reports boot-fix commit `8cbb1fa` merged as `ba791f1` and the `fix/jenkins-boot-network-wait` branch deleted locally and remotely; the local merge commit identifies PR #117. The conversation has 1,081 lines and was read in order. It references screenshots, but the shared text says images are hidden and does not include them. The internal state of `vprofile-src` was not checked. No live GitHub or AWS service check was made.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins Phase 1 startup verification. The boot-recovery code is merged and has reported local checks, but no AWS boot test has established that it fixes the startup failure. A clean Jenkins apply and a healthy controller, agent, and pipeline remain unverified. The earlier GitHub Actions deployment checkpoint remains separate and does not prove Jenkins works.

## Current status

**Durable and ephemeral infrastructure (author-supplied command output in the conversation):** A durable-layer apply reportedly added 10 resources. The ephemeral plan listed 24 additions; the first apply created 23 and failed on the tagged controller ingress rule because the Terraform identity lacked the required tag action. After the author approved a policy correction, a second apply reportedly added the remaining rule. The saved policy was not compared in full, so this proves only that the reported request succeeded in that run. The durable layer remains outside ephemeral teardown.

**First startup and teardown:** All three instances reportedly registered `Online` in AWS Systems Manager (SSM), AWS's service for managing cloud instances, but this did not establish a usable Jenkins service. In an author-approved EC2 console read, the controller system log showed repeated timeouts for plain HTTP (web traffic) on port 80 during `apt-get update`. The NAT gateway and route were reported active later; that does not prove they were ready during boot. The precise cause remains unconfirmed. A later ephemeral destroy reportedly removed all 24 resources, and limited state and resource queries returned empty results in `us-east-1`. These are conversation-reported results, not fresh checks. Billing and credit coverage were not checked.

**Merged Jenkins boot recovery (author-supplied output and local history):** The three boot-fix files were committed as `8cbb1fa` and merged through PR #117 as `ba791f1`. The author-supplied WSL output reports `bash -n` passing for both scripts, `terraform fmt -check` printing nothing, and `terraform validate` succeeding. The changes add retries capped at a fixed number of attempts for selected controller and agent bootstrap operations and Terraform ordering for their network dependencies. These local checks do not prove AWS permissions, network readiness, or a successful boot; no later plan, apply, controller/agent launch, or Jenkins pipeline run is reported. The original startup cause remains unconfirmed, and the agent boot log was not supplied.

**Identity, approval, and cost:** The latest direct WSL `aws sts get-caller-identity` output supplied in this conversation says refreshed credentials were still expired; `assumed-role/p3-terraform` is not verified. Before a future Terraform command, refresh credentials with the recorded `p3-new` MFA flow and verify the role in that same WSL shell. The $2 target was a planning estimate for two t3.medium Jenkins hosts over eight hours with manual stop checks, not an enforced cap. Billing and credit coverage were not checked. No new plan, apply, or spending is authorized.

## Next safe step

Before any AWS test, request a fresh plan and cost review. First establish a new `p3-new` multi-factor authentication (MFA, a sign-in with a second check) session and verify `assumed-role/p3-terraform` in that same WSL shell; then review a new plan and obtain separate apply approval. The previous approval is spent. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the PR #117 evidence, [NOTES.md](NOTES.md) for reusable boot-recovery lessons, and the [new-account design decision](docs/decisions/new-account-deployment-design.md) for trade-offs and limits.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. The latest identity output reports expired refreshed credentials, so authenticate again before Terraform. The supplied conversation reports clearing/counting AWS variables to 0 after teardown; that is shell-scoped evidence. The author reports signing out of root after the Jenkins IAM session; this was not independently checked, and the event date is not stated.
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
- [ ] After manual GitHub Actions deployment trigger #3, demonstrate the Build and Test workflow running automatically on a pull request or push to `main`; record the event, commit, and result. Keep deployment manual-only.
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins with recorded verification; a single clean Jenkins Terraform apply and successful controller/agent/pipeline run have not been demonstrated.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [x] Deployment to the approved target and health behavior are verified (the supplied conversation reports three dispatch outcomes and health checks; Run 3's commit header is missing, and the run evidence was not independently reopened).
- [x] Failure and same-app rollback control flow are meaningfully demonstrated (the supplied Run 2 summary reports `rescued=1`, post-restore checks, and the intentional final failure; restoring a different build and database rollback are not demonstrated).
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified (the latest teardown and four limited resource queries were reported successful; billing, credits, other Regions, and other resource types remain unchecked).
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean. The supplied output reports a clean `main` after PR #117; this documentation update remains uncommitted. The `vprofile-src` submodule's internal state is unknown.

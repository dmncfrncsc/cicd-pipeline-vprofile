# Project 3 session handoff

**Updated 2026-10-28.** The current checkout is `fix/jenkins-boot-network-wait` at `f45e822`. User-supplied output reports the Jenkins cost-rotation documentation branch merged and local main fast-forwarded to `f45e822`; that output did not show a PR number. At the start of this update, local status showed three unstaged code edits in the Jenkins agent boot script, controller boot script, and `infra/ephemeral/jenkins.tf`; no other tracked or untracked changes were listed when submodules were ignored. Those code edits are preserved. The `vprofile-src` internal state was not checked. The supplied Claude conversation has 2,626 text lines and was read in chronological chunks; its referenced screenshots were not included. No live GitHub or AWS check was made.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins Phase 1 startup recovery. The user has not demonstrated a one-time clean apply or a healthy Jenkins controller, agent, and pipeline. The earlier GitHub Actions deployment checkpoint remains separate and does not prove Jenkins works.

## Current status

**Durable and ephemeral infrastructure (author-supplied command output in the conversation):** A durable-layer apply reportedly added 10 resources. The ephemeral plan listed 24 additions; the first apply created 23 and failed on the tagged controller ingress rule because the Terraform identity lacked the required tag action. After the author approved a policy correction, a second apply reportedly added the remaining rule. The saved policy was not compared in full, so this proves only that the reported request succeeded in that run. The durable layer remains outside ephemeral teardown.

**First startup and teardown:** All three instances reportedly registered `Online` in AWS Systems Manager (SSM), AWS's service for managing cloud instances, but this did not establish a usable Jenkins service. In an author-approved EC2 console read, the controller system log showed repeated timeouts for plain HTTP (web traffic) on port 80 during `apt-get update`. The NAT gateway and route were reported active later; that does not prove they were ready during boot. The precise cause remains unconfirmed. A later ephemeral destroy reportedly removed all 24 resources, and limited state and resource queries returned empty results in `us-east-1`. These are conversation-reported results, not fresh checks. Billing and credit coverage were not checked.

**Local Jenkins boot-fix edits:** On the current branch, three tracked files are modified and unstaged: `infra/ephemeral/files/jenkins-agent-boot.sh`, `infra/ephemeral/files/jenkins-controller-boot.sh`, and `infra/ephemeral/jenkins.tf`. The conversation reports passing `bash -n` checks for both scripts and Terraform formatting/validation checks in WSL. These checks were not rerun here, and no AWS plan or apply tested the edits. Retries for the `Plugin Installation Manager` download and controller Systems Manager parameter calls remain open; the agent boot log was not supplied.

**Identity, approval, and cost:** A direct WSL `aws sts get-caller-identity` output supplied in this conversation says the refreshed credentials were still expired; the identity is not currently verified. The approved $2 target was for planning two t3.medium Jenkins hosts over eight hours with manual stop checks. It is not an enforced cap, and no billing or credit check was reported. Earlier approval does not authorize another plan, apply, or spend.

## Next safe step

Review the three existing code edits and the remaining one-shot startup calls; decide whether any further code correction is needed. Before any Terraform command, establish a fresh session and verify `assumed-role/p3-terraform` in that same WSL shell. A new plan and any later apply need their own authorization; the earlier apply approval is spent. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for chronology and evidence limits, [NOTES.md](NOTES.md) for reusable lessons, and the [new-account design decision](docs/decisions/new-account-deployment-design.md) for the recorded trade-offs.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. The latest supplied output reports clearing/counting AWS variables to 0 after teardown; that is shell-scoped evidence. The author reports signing out of root after the Jenkins IAM session; this was not independently checked, and the event date is not stated.
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
- [ ] Repository cleanup is complete and Git status is clean. This checkpoint's documentation and three Jenkins code edits remain unstaged; the vprofile-src submodule's internal state is unknown.

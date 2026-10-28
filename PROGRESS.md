# Project 3 session handoff

**Updated 2026-10-28.** Local Git shows `main`, `origin/main`, and `HEAD` at `3055a3c` (PR #119), with the current branch `fix/jenkins-awscli-installer` based there. Before documentation edits, status with submodules ignored showed only the two Jenkins boot scripts modified; no staged or untracked files were reported. Regular status cannot access the `vprofile-src` submodule metadata, so its internal state is unknown. The supplied 968-line continuation was read in order; its shared copy says images are hidden. No live GitHub or AWS service check was made.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins Phase 1 startup recovery. The author selected AWS's documented AWS CLI v2 x86_64 zip installer to replace the `awscli` apt package that had no installation candidate in the reported boot test. Both local boot scripts now call the installer through their retry helper; the signature check is skipped as an accepted trade-off. Local checks passed, but these edits are uncommitted, unmerged, and not boot-tested. No successful Jenkins controller, agent connection, or pipeline is established. The earlier GitHub Actions deployment checkpoint is separate.

## Current status

**Durable and ephemeral infrastructure (author-supplied command output in the conversation):** A durable-layer apply reportedly added 10 resources. The ephemeral plan listed 24 additions; the first apply created 23 and failed on the tagged controller ingress rule because the Terraform identity lacked the required tag action. After the author approved a policy correction, a second apply reportedly added the remaining rule. The saved policy was not compared in full, so this proves only that the reported request succeeded in that run. The durable layer remains outside ephemeral teardown.

**Jenkins boot test and teardown (author-supplied command output and controller log):** The test plan with `enable_jenkins=true` reported 24 additions; an earlier plan without that input reported 14 because Jenkins resources defaulted off. The apply reported 24 resources added, and all three instances showed `Online` in SSM; that confirms agent connectivity only, not Jenkins health. The controller log reported that Ubuntu package indexes downloaded 35.8 MB without the earlier port 80 timeouts, then the AWS CLI (`awscli` package), a command-line tool for AWS, had no installation candidate across 10 attempts and cloud-init (Ubuntu's first-boot setup service) failed. Jenkins never started; the agent log was not read. This supports the network recovery in that test, but the original timeout cause remains unconfirmed. The author-supplied destroy output reports 24 removed; state count was 0 and limited instance, NAT-gateway, and Elastic-IP queries returned no results in `us-east-1`. Other Regions/resource types, billing, and credit coverage were not checked. These are reported results, not fresh checks.

**Merged Jenkins boot recovery (author-supplied output and local history):** The three boot-fix files were committed as `8cbb1fa` and merged through PR #117 as `ba791f1`. The author-supplied WSL output reports `bash -n` passing for both scripts, `terraform fmt -check` printing nothing, and `terraform validate` succeeding. The changes add retries capped at a fixed number of attempts for selected controller and agent bootstrap operations and Terraform ordering for their network dependencies. These local checks do not prove AWS permissions, network readiness, or a successful boot; no later plan, apply, controller/agent launch, or Jenkins pipeline run is reported. The original startup cause remains unconfirmed, and the agent boot log was not supplied.

**AWS CLI installer change (local, author-supplied output):** On `fix/jenkins-awscli-installer`, both `infra/ephemeral/files/jenkins-controller-boot.sh` and `infra/ephemeral/files/jenkins-agent-boot.sh` replace the apt `awscli` dependency with a retry-wrapped AWS CLI v2 zip install. The controller package list adds `unzip`; the agent already included it. The author reports both `bash -n` checks passed, `terraform fmt -check` printed nothing, and `terraform validate` succeeded after the MFA profile flow; the author reported the identity as `assumed-role/p3-terraform`. No commit, PR, plan, apply, or boot test followed. The identity output itself was not pasted, and the credentials later produced an expired-refresh error, so repeat the same-shell identity check before any Terraform command. The installer guard currently treats any successful `aws --version` as installed; it does not explicitly check that the version is v2.

**Identity, approval, and cost:** The author reported completing MFA before the test; the supplied transcript does not include a separate `get-caller-identity` result. An AWS `GetConsoleOutput` denial identifies the caller as `assumed-role/p3-terraform`, and the later plan/apply outputs succeeded. Before any new Terraform command, use the documented `p3-new` flow and verify the role in that same WSL shell; current credentials have not been checked. The $2 target was a planning estimate for two t3.medium Jenkins hosts over eight hours, not a cap. The reported test lasted about 10 minutes, but billing and credit coverage were not checked. The apply approval was for that test and is spent; no new plan, apply, or spending is authorized.

## Next safe step

Review the version check in the local installer helper and confirm in Git Bash that only the two intended scripts are modified before committing and opening a PR. These local edits have not been boot-tested. Any later Terraform plan needs a fresh same-shell identity check, cost review, and separate approval; the previous apply approval is spent. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence, [NOTES.md](NOTES.md) for reusable lessons, and the [new-account design decision](docs/decisions/new-account-deployment-design.md) for the installer choice and limits.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. The author reported the intended role after reloading MFA credentials, but a later expired-refresh error means credentials must be checked again. The supplied conversation reports clearing/counting AWS variables to 0 after teardown; that is shell-scoped evidence. The author reports signing out of root after the Jenkins IAM session; this was not independently checked, and the event date is not stated.
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
- [ ] Repository cleanup is complete and Git status is clean. Local refs place `main` at PR #119 merge commit `3055a3c`; the two AWS CLI installer script edits and four documentation edits remain unstaged and uncommitted. The `vprofile-src` submodule's internal state is unknown.

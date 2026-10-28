# Project 3 session handoff

**Updated 2026-10-29.** The supplied 487-line continuation was read in full and in order. The author dates the third Jenkins test actions to 2026-10-28; the shared transcript marks some images/files hidden, so their contents were unavailable. Its terminal output reports PR #123 merged and `main` fast-forwarded to `e8e88ee`; this workspace's local `HEAD` is also `e8e88ee`. The worktree was clean before this documentation update when submodules were ignored; the `vprofile-src` submodule's internal state was not checked. No live GitHub or AWS service check was made.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins Phase 1 startup re-test in progress. The second reported boot test installed AWS CLI v2.39.0 on the controller, then Jenkins 2.580.1 failed to initialize because JCasC rejected `excludeClientIPFromCrumb`. The setting was traced to the pinned commit's `jenkins/casc.yaml` and removed in PR #122 (`3e00f89`). The third test's saved plan and apply are reported successful, but neither controller nor agent logs have been read; no Jenkins startup, agent connection, or pipeline success is verified.

## Current status

**Durable and ephemeral infrastructure (author-supplied command output in the conversation):** A durable-layer apply reportedly added 10 resources. The ephemeral plan listed 24 additions; the first apply created 23 and failed on the tagged controller ingress rule because the Terraform identity lacked the required tag action. After the author approved a policy correction, a second apply reportedly added the remaining rule. The saved policy was not compared in full, so this proves only that the reported request succeeded in that run. The durable layer remains outside ephemeral teardown.

**Jenkins boot test and teardown (author-supplied command output and controller logs):** The first Jenkins test showed 24 instances/resources added, all three instances `Online` in SSM, and a controller package-index download without the earlier port 80 timeouts; the `awscli` apt package was unavailable after 10 attempts and Jenkins did not start. PR #120 replaced that package step with AWS CLI v2 zip installation. The second test's controller log reported AWS CLI v2.39.0 installed, then Jenkins 2.580.1 failed JCasC initialization on `excludeClientIPFromCrumb`. The agent log was not read. After teardown, the author-supplied output reported 24 destroyed, `terraform state list` count 0, three instances `terminated`, a NAT gateway `deleted`, and no Elastic IPs in `us-east-1`. These checks do not cover other Regions/resource types, billing, or credit coverage, and were not rerun here.

**Merged Jenkins boot recovery (author-supplied output and local history):** The three boot-fix files were committed as `8cbb1fa` and merged through PR #117 as `ba791f1`. The author-supplied WSL output reports `bash -n` passing for both scripts, `terraform fmt -check` printing nothing, and `terraform validate` succeeding. The changes add retries capped at a fixed number of attempts for selected controller and agent bootstrap operations and Terraform ordering for their network dependencies. These local checks do not prove AWS permissions, network readiness, or a successful boot; no later plan, apply, controller/agent launch, or Jenkins pipeline run is reported. The original startup cause remains unconfirmed, and the agent boot log was not supplied.

**AWS CLI installer change (merged as PR #120; author-supplied output):** Both `infra/ephemeral/files/jenkins-controller-boot.sh` and `infra/ephemeral/files/jenkins-agent-boot.sh` replace the apt `awscli` dependency with a retry-wrapped AWS CLI v2 zip install. The controller package list adds `unzip`; the agent already included it. Before merge, the author reported both `bash -n` checks passed, `terraform fmt -check` printed nothing, and `terraform validate` succeeded after the MFA profile flow. PR #120 is reported merged at `77fbd46`; the second test's controller log later confirmed AWS CLI v2.39.0. The installer guard treats any successful `aws --version` as installed and does not explicitly check that the version is v2; the subsequent controller log proves v2 installed in this test, but not that the guard is reliable on every image.

**Second boot test and fix (author-supplied terminal output, local history, and official Jenkins source review):** PR #120 merged the AWS CLI installer change at `77fbd46`. The corrected second-test plan reported 24 additions and the apply reported 24 added. Jenkins 2.580.1 failed with exit status 5 after JCasC rejected `excludeClientIPFromCrumb`. The supplied Git output traced the setting to `jenkins/casc.yaml` in pinned commit `0163e2cf4b772bac7ebb5f6d05c1f014eb9ffe10`; the controller boot script fetches the repository's `jenkins/` files at that configured commit. PR #122 removed the three-line `crumbIssuer` block and merged at `3e00f89fe9d26729a83563e90a11ea9bee53da4f`. The supplied `git grep` of that commit found no remaining `crumbIssuer` under `jenkins/`. At this checkpoint, Jenkins had not yet been boot-tested with the fix; the later test is summarized below. Other config errors may remain. The agent log and its install/connection are unknown. The official Jenkins sources and limits are linked in `NOTES.md`.

**Third Jenkins boot test after PR #122 (author-supplied output; event date 2026-10-28):** The saved plan reported 24 additions, zero changes, and zero destroys. `terraform show -json` output confirmed `jenkins_config_commit=3e00f89fe9d26729a83563e90a11ea9bee53da4f`. The author approved applying exactly that saved plan; Terraform output reported 24 added, zero changed, and zero destroyed. A subsequent WSL `aws ssm start-session` request for the controller returned `AccessDeniedException` for `ssm:StartSession`. That denial does not establish whether Jenkins started. The transcript next proposes EC2 console output or SSM Run Command (Systems Manager's feature for running commands on an instance without opening an interactive session), but provides no output from either. Controller and agent logs, teardown, live resource state, and billing/credit coverage remain unverified. Until teardown is verified, treat the test resources as potentially active and billable.

**Identity, approvals, teardown, and cost:** Before the second test, the author reported the same-shell identity as `assumed-role/p3-terraform`; the corrected 24-resource plan and apply then succeeded. For the third test, the author again reported the role/account match, but the transcript contains no identity command output. The author explicitly approved application of the exact third-test saved plan; that approval did not cover teardown. The author waived a repeat cost review for the unchanged setup, but billing and credit coverage were not checked. The $2 target is a planning estimate, not a bill cap. Verify the intended identity in the same WSL shell before any future Terraform command.
## Next safe step

First, retrieve and review the controller and agent logs through an authorized access method; the transcript's direct `start-session` request was denied, and its suggested console-output and Run Command alternatives have no results yet. Do not infer Jenkins health from the access denial or change permissions as a shortcut. Then create and review a destroy plan in the same WSL shell after confirming the intended identity; review the resources and obtain separate approval before applying it. Verify teardown with bounded read-only checks, and record billing/credit limits without claiming they were checked. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the test evidence, [NOTES.md](NOTES.md) for reusable lessons, and the [new-account design decision](docs/decisions/new-account-deployment-design.md) for the decision status.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. For the third test, the author reported the role/account match but supplied no identity command output; verify again before any future Terraform command. The supplied conversation reports clearing/counting AWS variables to 0 after teardown; that is shell-scoped evidence. The author reports signing out of root after the Jenkins IAM session; this was not independently checked, and the event date is not stated.
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
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins with recorded verification; after PR #122 removed the rejected crumb setting, the third test's plan and 24-resource apply were reported successful, but controller/agent logs, Jenkins startup, agent connection, pipeline, and teardown remain unverified.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [x] Deployment to the approved target and health behavior are verified (the supplied conversation reports three dispatch outcomes and health checks; Run 3's commit header is missing, and the run evidence was not independently reopened).
- [x] Failure and same-app rollback control flow are meaningfully demonstrated (the supplied Run 2 summary reports `rescued=1`, post-restore checks, and the intentional final failure; restoring a different build and database rollback are not demonstrated).
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified (the third test's resources have no reported teardown; billing and credit coverage were not checked).
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean. Before this documentation update, the worktree was clean with submodules ignored; this update's documentation changes are unstaged. The `vprofile-src` submodule's internal state is unknown.

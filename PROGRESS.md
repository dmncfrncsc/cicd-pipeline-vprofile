# Project 3 session handoff

**Updated 2026-10-29.** This handoff reflects the complete accessible text of the supplied shared conversation. Its attachment label says 2,107 lines; a local line count returned 1,688, so the counts differ. The full readable text was reviewed; files/images marked hidden in the shared conversation were unavailable. The event dates for this continuation were not stated; 2026-10-29 is the documentation date, not an inferred event date. The local branch is `main` at `0b9a2fb`, matching the local `origin/main` ref; no live GitHub check was made. Local status still reports `infra/ephemeral/files/jenkins-agent-boot.sh` as modified, although an earlier blob-hash comparison matched `HEAD`; the reason for the status discrepancy was not established. The file was not changed here. The local parent-folder copies of Master Prompt v5.2 and Project Instructions v4.2 match the supplied attachments; whether either is adopted in Claude Project Knowledge is unknown.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** prepare a fourth Jenkins startup test to exercise the merged agent-online check. The test has not been applied. Jenkins remains required before project completion; pipeline execution through Jenkins, verified deployment parity, and a successful agent connection remain outstanding.

## Current status

**Third Jenkins test and teardown (author-supplied logs and terminal output):** The controller log reported AWS CLI v2.39.0 installed, Jenkins 2.580.1 started, and `p3: controller boot finished. Security check passed.` The supplied controller script shows that this message follows Jenkins HTTP readiness, an anonymous 401/403 response, a successful admin API response, and the agent-secret handoff. The agent log reported its service started and `p3: agent boot finished`; `systemctl is-active` does not prove that the agent authenticated or appeared online. No successful Jenkins pipeline was reported. The author later reported a destroy plan and apply of 24 resources, an empty ephemeral Terraform state, three terminated instances, a deleted NAT gateway, and no Elastic IPs in `us-east-1`. These checks cover only the reported state and resource types in that Region; billing, credit coverage, and other resources/Regions were not checked.

**Health-check design and merged implementation:** The author chose boot-time reporting rather than granting `p3-terraform` instance access or creating a separate verification role. PR #125 reportedly added `.gitattributes` with `*.sh text eol=lf`; PR #126 reportedly added a controller-side poll of `/computer/p3-agent/api/json` for 120 attempts with 5-second sleeps. The script's up-to-10-second HTTP request timeout means elapsed wall-clock time can exceed the nominal 600 seconds. A match for HTTP 200 and `"offline": false` prints PASS; timeout or another last state prints FAIL and exits non-zero without stopping Jenkins. The node name `p3-agent` is present in the supplied `jenkins/casc.yaml`. These PR/merge details are conversation-reported; local `HEAD` is `0b9a2fb`. The endpoint, response match, and PASS/FAIL behavior have not been verified by a real boot.

**Terraform wiring and fourth-test planning:** Local `infra/ephemeral/jenkins.tf` loads both scripts from the checkout with Terraform `file()` and puts them into EC2 user data (startup instructions passed to an instance); `jenkins_config_commit` separately pins the remote Jenkins configuration files. Changing user data is configured to replace the affected instance. The first fourth-test plan completed with 14 additions because `enable_jenkins` defaults to `false` and gates ten Jenkins resources. Attempts with Jenkins enabled then failed a resource precondition because role/profile inputs were missing; an interim `22 to add` before the error was not a completed plan. The durable Terraform files identify the intended profile and deploy-role names, but their live AWS existence was not checked. No successful complete fourth-test plan or apply was reported, and no post-plan live AWS check was made.

**Access, cost, and security limits:** The supplied conversation reports `ec2:GetConsoleOutput`, `ssm:StartSession`, and `ssm:SendCommand` denied for `p3-terraform`; the author read logs in the EC2 console, and no role permissions were broadened. The author waived a repeat cost review for the unchanged test setup and asked for a short run; this is not a billing or credit check. The boot output listed Jenkins plugin advisory warnings that were not researched. Do not describe the plugin set as security-cleared.

**Line endings and local validation:** `bash -n` caught CRLF line endings in the controller script; later supplied checks reported both scripts at zero carriage returns, successful shell syntax checks, `terraform fmt -check` with no output, and `terraform validate` success. Git Bash reported `core.autocrlf=true`; WSL had no reported setting, producing line-ending-only changes in its status/diff view. The `.gitattributes` rule was merged per the conversation. These checks do not exercise Jenkins or its agent API.

## Next safe step

In the WSL shell, verify `assumed-role/p3-terraform` and the intended account, then create a fresh, complete plan with `enable_jenkins=true`, the approved full configuration commit, and the controller profile, agent profile, and deploy-role values from `infra/durable/jenkins-roles.tf`. Review the complete plan and resource list; the previous failed plans are not applicable. Do not apply until that exact complete plan is reviewed and approved. If the test proceeds, read the controller system log for PASS/FAIL and tear down promptly, then repeat the bounded teardown checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [deployment design decision](docs/decisions/new-account-deployment-design.md).

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. A failed plan or a partial resource count is not an actionable plan.
- Keep account IDs, credentials, VProfile source, and WAR contents out of the public repository and workflow logs. Public pull-request workflows stay build/test only. Do not use the instructor's `Jenkinsfile` without a focused need and approval, or reuse other projects' resources without an approved design and verified ownership.
- Do not use AWS Organizations or set up Control Tower; pause before other account-wide actions. Keep Terraform state backups outside Git and do not alter state to investigate metadata discrepancies.
- Documentation edits do not authorize AWS changes, spending, deployments, or Git state changes. The author handles staging, commits, pushes, merges, and cleanup.

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
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins with recorded verification. PR #126 reportedly added the boot-time agent-online check, but its API match has not been tested on a real boot; no Jenkins pipeline success is reported.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [x] Deployment to the approved target and health behavior are verified (the supplied conversation reports three dispatch outcomes and health checks; Run 3's commit header is missing, and the run evidence was not independently reopened).
- [x] Failure and same-app rollback control flow are meaningfully demonstrated (the supplied Run 2 summary reports `rescued=1`, post-restore checks, and the intentional final failure; restoring a different build and database rollback are not demonstrated).
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified. The third-test teardown checks were reported for the ephemeral state and selected resource types in `us-east-1`; billing, credits, and broader resource coverage remain unchecked. The fourth-test plan is incomplete and has not been applied.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean. Before this documentation update, status showed the pre-existing agent boot-script modification; this update changes four documentation files. The `vprofile-src` submodule's internal state was not checked.

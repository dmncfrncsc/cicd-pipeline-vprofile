# Project 3 session handoff

**Updated 2026-10-29.** This handoff reflects the complete accessible text of the supplied conversation attachment, labeled 876 lines; its readable text has 652 newline-delimited lines. Some shared files are marked hidden and unavailable. The local parent-folder copies of Master Prompt v5.2 and Project Instructions v4.2 were checked. The local branch is `main` at `ebc61b3` (PR #127 merge); no live GitHub check was made. The working tree reports `infra/ephemeral/files/jenkins-agent-boot.sh` modified. The supplied Git Bash output showed no content diff, including with CR-at-EOL ignored, and zero carriage returns in both boot scripts, but the reason for the persistent status marker remains unknown. This file was not changed here.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins design, after a fourth startup test. Jenkins remains required before project completion. The test's boot-time controller and agent checks passed, but no Jenkins pipeline has run; job wiring, private source access, and SSM UI access remain design work.

## Current status

**Third Jenkins test and teardown (author-supplied logs and terminal output):** The controller log reported AWS CLI v2.39.0 installed, Jenkins 2.580.1 started, and `p3: controller boot finished. Security check passed.` The supplied controller script shows that this message follows Jenkins HTTP readiness, an anonymous 401/403 response, a successful admin API response, and the agent-secret handoff. The agent log reported its service started and `p3: agent boot finished`; `systemctl is-active` does not prove that the agent authenticated or appeared online. No successful Jenkins pipeline was reported. The author later reported a destroy plan and apply of 24 resources, an empty ephemeral Terraform state, three terminated instances, a deleted NAT gateway, and no Elastic IPs in `us-east-1`. These checks cover only the reported state and resource types in that Region; billing, credit coverage, and other resources/Regions were not checked.

**Fourth Jenkins test and teardown (author-supplied WSL output and EC2 system-log excerpt):** After a complete saved Terraform plan file (the reviewed set of intended changes) reported 24 additions, the author approved applying `test4.tfplan`; the apply reported 24 added, zero changed, and zero destroyed. The plan used `jenkins_config_commit=babd990c6f06fe2d5c467ae0373cd38a276b108a`. The controller log showed `p3: controller boot finished. Security check passed.` followed about six seconds later by `p3: PASS agent p3-agent is online`. This is the first reported real boot of the PR #126 online check. No Jenkins pipeline or deployment was run, and the plugin security advisories remain unreviewed. The author then reported an empty Terraform state and empty query results for pending/running/stopping/stopped EC2 instances, pending/available/deleting NAT gateways, and Elastic IPs in `us-east-1`. These checks do not establish billing, credit coverage, or the absence of other resource types or resources in other Regions. Test costs were not independently reviewed.

**Health-check design and merged implementation:** The author chose boot-time reporting rather than granting `p3-terraform` instance access or creating a separate one-off verification role. PR #125 reportedly added `.gitattributes` with `*.sh text eol=lf`; PR #126 reportedly added a controller-side poll of `/computer/p3-agent/api/json` for 120 attempts with 5-second sleeps. The script's up-to-10-second HTTP request timeout means elapsed wall-clock time can exceed the nominal 600 seconds. A match for HTTP 200 and `"offline": false` prints PASS; timeout or another last state prints FAIL and exits non-zero without stopping Jenkins. The node name `p3-agent` is present in the supplied `jenkins/casc.yaml`. The fourth-test log now supports that the check passed on one real boot; it is still a boot-time snapshot, not continuing monitoring. The PR history is conversation-reported; local `HEAD` is now `ebc61b3`.

**Terraform wiring and planning:** Local `infra/ephemeral/jenkins.tf` loads both scripts from the checkout with Terraform `file()` and puts them into EC2 user data (startup instructions passed to an instance); `jenkins_config_commit` separately pins the remote Jenkins configuration files. Changing user data is configured to replace the affected instance. Early fourth-test attempts failed or planned only the base stack; the later complete 24-resource plan and apply are recorded above. The author-supplied output confirmed the controller and agent profiles and Jenkins deploy role existed in the account at test time. This does not establish that the resources remain present or that a future plan is safe.

**Access, cost, and security limits:** The supplied conversation reports `ec2:GetConsoleOutput`, `ssm:StartSession`, and `ssm:SendCommand` denied for `p3-terraform`; the author read logs in the EC2 console, and no role permissions were broadened. The author waived a repeat cost review for the unchanged test setup and asked for a short run; this is not a billing or credit check. The boot output listed Jenkins plugin advisory warnings that were not researched. Do not describe the plugin set as security-cleared.

**Line endings and local validation:** `bash -n` caught CRLF line endings in the controller script; later supplied checks reported both scripts at zero carriage returns, successful shell syntax checks, `terraform fmt -check` with no output, and `terraform validate` success. Git Bash reported `core.autocrlf=true`; an earlier WSL diff showed line-ending-only noise. In the later Git Bash check, the agent script still showed `M` in status while regular and CR-at-EOL-ignored diff stats were empty; the reason remains unknown. The `.gitattributes` rule was merged per the conversation. These checks do not exercise Jenkins or its agent API.

## Next safe step

Continue design only: review the proposed SSM (AWS Systems Manager) UI-access design and decide whether it is acceptable before any role, policy, document, or Terraform implementation is proposed for approval. The current direction is a dedicated operator role requiring MFA (multi-factor authentication), a custom Session document (a configuration that controls the session type and port) fixing the remote port at 8080, and a controller-tag condition; it is not implementation approval. Then resolve the Jenkins job wiring in `jenkins/casc.yaml` and the safe way to fetch private VProfile source. Do not launch resources until a separate cost review and explicit implementation/apply approvals. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [deployment design decision](docs/decisions/new-account-deployment-design.md).

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. A failed plan or a partial resource count is not an actionable plan.
- Keep account IDs, credentials, VProfile source, and WAR contents out of the public repository and workflow logs. Public pull-request workflows stay build/test only. The author chose a repo-stored, independently designed `Jenkinsfile` (the file that defines Jenkins pipeline steps); job wiring and private-source access are unresolved. Do not inspect or reuse the instructor's Jenkinsfile or course provisioning scripts.
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
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins with recorded verification. The fourth-test log reports the controller boot checks and agent-online check passed on one boot; no Jenkins pipeline or deployment has run.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [x] Deployment to the approved target and health behavior are verified (the supplied conversation reports three dispatch outcomes and health checks; Run 3's commit header is missing, and the run evidence was not independently reopened).
- [x] Failure and same-app rollback control flow are meaningfully demonstrated (the supplied Run 2 summary reports `rescued=1`, post-restore checks, and the intentional final failure; restoring a different build and database rollback are not demonstrated).
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified. The fourth-test teardown output reports empty ephemeral state and no matching active instances, NAT gateways, or Elastic IPs in `us-east-1`; billing, credits, other resource types, and other Regions remain unchecked.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean. Before this documentation update, status showed the existing agent boot-script modification; author-supplied diff commands showed no content difference and the cause remains unknown. This update changes the four documentation files; the `vprofile-src` submodule's internal state was not checked.

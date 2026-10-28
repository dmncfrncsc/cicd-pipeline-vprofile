# Project 3 session handoff

**Updated 2026-10-28.** Local `main`, `origin/main`, and `HEAD` are at `08f982b` (PR #110). Before this documentation update, status with submodules ignored showed `NOTES.md` modified and five untracked files: the controller boot script, JCasC and plugin files, the agent-secret hook, and `scripts/teardown-ephemeral.sh`. Regular status fails because Git cannot access `vprofile-src` metadata; its state is unknown. The attached 1,072-line conversation has no event timestamp; local file presence and Git state were checked for this handoff, but no live GitHub or AWS check was made. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins J1 repository setup is in progress under the author's approval for Phase 1 files only. The selected design uses the existing ephemeral Terraform root, an off-by-default `enable_jenkins` switch, a separate Jenkins deploy role, and the existing NAT and WAR bucket. No Terraform plan/apply, IAM edit, AWS resource, workflow run, or Jenkins test is authorized or recorded.

## Current status

**Repository:** Local refs show `main`, `origin/main`, and `HEAD` at `08f982b`. Before this update, `NOTES.md` was already modified and `scripts/teardown-ephemeral.sh` was already untracked. Four additional untracked drafts are present: `infra/ephemeral/files/jenkins-controller-boot.sh`, `jenkins/casc.yaml`, `jenkins/plugins.txt`, and `jenkins/init-agent-secret.groovy`. The Jenkins drafts are incomplete: the agent boot script, `infra/ephemeral/jenkins.tf`, durable Jenkins roles and bucket public-access-block resources, and `Jenkinsfile` are absent. Regular status fails on the inaccessible `vprofile-src` metadata; status with submodules ignored succeeds, but the submodule's own state remains unknown.

**Deployment and rollback (conversation-reported):** three dispatches reportedly ended normal green, forced-failure red after successful same-app restore, and normal green. This supports same-app file restore, not recovery to a different build or database rollback; Run 3's commit was not supplied. The `/users` retry fix ran, but the output does not show whether a retry occurred. Login, real-user behavior, search, and app-level RabbitMQ/Memcached use remain unverified. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the run details and evidence limits.

**IAM and teardown (conversation-reported):** one plain `terraform destroy` reportedly removed 14 resources, followed by empty state and four empty resource queries in `us-east-1`. Policy Version 5 of 5 was reported Default and attached to `p3-terraform`, but full policy text and effective permissions were not checked. One success does not explain the earlier 403 or prove repeat reliability. Billing, credits, other Regions, and other resource types remain unchecked. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the teardown sequence and evidence limits.

**Jenkins choices and research:** Jenkins 2.580.1 LTS, Java 21 for controller and agent, Java 17 for the Maven build, Plugin Installation Manager (a command-line tool that downloads plugins and their dependencies) 2.15.0, and JCasC `readFile` syntax are supported by official-source findings in the supplied conversation. The current controller draft uses those choices; its plugin list pins only JCasC. Ansible `2.21.4` and Session Manager plugin `1.2.835.0` are also selected for planning. These versions and configuration have not been installed or tested on a Jenkins host. The agent Java connection, Groovy hook ordering, package version string, pinned download URL, and SSM session identity remain lab checks.

**Secrets and policy:** the author selected one-time rotation of the DB and RabbitMQ passwords, then keeping matching copies in GitHub secrets and `/p3/app/` Parameter Store parameters. This is not done; no secret values are in the repository. The controller should read only those two exact parameter ARNs. Jenkins instances must use `Project=p3-vprofile-jenkins`; the UI policy also requires `Role=jenkins-controller`, preserving the existing deploy role's `Project=p3-vprofile` scope. A separate role for the Jenkins deploy path, durable bucket public-access blocks, and one reviewed `p3-terraform` policy edit remain unimplemented. The review-only UI policy remains unapplied.

**Bootstrap and teardown:** JCasC (Jenkins Configuration as Code, a plugin that applies settings from YAML) creates the admin account, agent node, credentials, and manual job. The controller boot draft uses a fail-closed startup check (stop Jenkins unless anonymous access is denied and the admin login succeeds) before publishing the agent secret; this ordering is untested. Jenkins-only teardown is planned by turning `enable_jenkins` off and confirming the plan changes no app or network resources. A separate, approved full ephemeral destroy would remove the app and NAT too. The existing untracked teardown helper is unreviewed and unrun; it contains a targeted NAT destroy followed by a full destroy, so it is not an approved Jenkins-only cleanup method.

**Cost note:** the conversation reports about `$0.50` as the incremental two-instance compute floor and a `$2` planning target with an 8-hour stop rule. These are not a current quote or an approved automatic stop; NAT data, storage, other app costs, billing, and credit coverage are not verified.

**Other recorded risks:** Terraform state differs from its preserved backup; some Sonar findings remain accepted; prior-account cleanup and charges are unknown. Full evidence is in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), reusable details in [NOTES.md](NOTES.md), and Jenkins decisions in the [design record](docs/decisions/new-account-deployment-design.md). No current billing/credit check or monthly budget is recorded.

## Next safe step

Complete and review the remaining Phase 1 repository drafts: agent boot script, `jenkins.tf` with the off-by-default switch and tags, durable role and bucket-protection resources, and the Jenkinsfile. Then review the exact file set and evidence before any merge. The existing app target, NAT, SSM path, IAM permissions, secret rotation, and teardown behavior remain untested in this design. Do not run Terraform, change IAM or GitHub settings, create AWS resources, or spend without their separate approvals. The automatic Build and Test demonstration after deployment trigger #3 remains pending separately.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. The latest supplied output reports clearing/counting AWS variables to 0 after teardown; that is shell-scoped evidence. Root sign-out after the Version 5 edit was reported, not independently checked.
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
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins, each with recorded verification.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified with outcomes and limits recorded; the bootstrap `terraform:S6258` finding is accepted, not fixed, and test coverage is not configured.
- [x] Source-use risk stance is documented and the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [x] Deployment to the approved target and health behavior are verified (the supplied conversation reports three dispatch outcomes and health checks; Run 3's commit header is missing, and the run evidence was not independently reopened).
- [x] Failure and same-app rollback control flow are meaningfully demonstrated (the supplied Run 2 summary reports `rescued=1`, post-restore checks, and the intentional final failure; restoring a different build and database rollback are not demonstrated).
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified (the latest teardown and four limited resource queries were reported successful; billing, credits, other Regions, and other resource types remain unchecked).
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean (the attached conversation reports successful teardown checks, but Jenkins bootstrap drafts and the teardown helper are untracked; documentation edits in this handoff are uncommitted; `vprofile-src` status is unknown).

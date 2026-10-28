# Project 3 session handoff

**Updated 2026-10-28.** Local `main`, `origin/main`, and `HEAD` are at `de061f2`. Before these documentation edits, status with submodules ignored showed the Jenkins policy candidate modified and the Jenkins instance-boundary candidate untracked. Git could not inspect `vprofile-src`, so its internal status remains unknown. The supplied 1,908-line conversation has no event timestamp. No live AWS or GitHub check was made here. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** Jenkins Phase 1 repository drafts are merged, but no Jenkins host, agent, or pipeline has been tested. The author reports a 14-statement count for `p3-terraform-jenkins` and a six-statement count for the Jenkins instance permissions boundary (a policy that caps permissions allowed for a role). The saved JSON was not compared with the review copies, and attachment to `p3-terraform` is not confirmed by the text available here. The cost gate, one-time password rotation, and Terraform plan/apply remain open and separately gated.

## Current status

**Repository:** Local `main`, `HEAD`, and the local `origin/main` ref are at `de061f2`; the supplied terminal output shows a fast-forward from `acb21fb`. PR #112 had already merged the nine Jenkins Phase 1 files listed in the earlier checkpoint. Before these documentation edits, `git status --short --untracked-files=all --ignore-submodules=all` showed `docs/drafts/new-account-jenkins-iam-policy-candidate.md` modified and `docs/drafts/new-account-jenkins-instance-boundary-candidate.md` untracked. A regular status command failed because Git could not access `vprofile-src` metadata; its internal status is unknown. No live GitHub check was made.

**Deployment and rollback (conversation-reported):** three dispatches reportedly ended normal green, forced-failure red after successful same-app restore, and normal green. This supports same-app file restore, not recovery to a different build or database rollback; Run 3's commit was not supplied. The `/users` retry fix ran, but the output does not show whether a retry occurred. Login, real-user behavior, search, and app-level RabbitMQ/Memcached use remain unverified. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the run details and evidence limits.

**IAM and teardown (conversation-reported):** one plain `terraform destroy` reportedly removed 14 resources, followed by empty state and four empty resource queries in `us-east-1`. An earlier checkpoint reported policy Version 5 of 5 as Default and attached to `p3-terraform`; a later `ListAttachedRolePolicies` read returned `AccessDenied`, so the current attachment set is not confirmed. The full policy text and effective permissions were not checked. One destroy success does not explain the earlier 403 or prove repeat reliability. Billing, credits, other Regions, and other resource types remain unchecked. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the teardown sequence and evidence limits.

**Jenkins implementation status:** the nine Phase 1 files are merged in PR #112, but remain untested and unapplied. The conversation reports the SonarCloud Quality Gate (an automated pass/fail check on code analysis) initially failed on a Security Rating (Sonar's letter grade summarizing security findings) of E; eight findings were fixed in the Terraform/boot-script drafts and three were marked accepted with written reasons. A later screenshot was reported to show the gate passing; this was not independently checked. Seventeen other new issues were reported without a condition set. No Jenkins host, agent, pipeline, or Terraform plan/apply was tested. The author reports the two Jenkins IAM policy statement counts, but the saved JSON and attachment status remain unverified.

**Secrets and policy:** one-time DB and RabbitMQ password rotation and matching GitHub/Parameter Store values remain planned, not done. The controller should read only the two exact `/p3/app/` parameters. The merged drafts use `Project=p3-vprofile-jenkins`; the controller also uses `Role=jenkins-controller`. The author reports that the separate `p3-terraform-jenkins` policy has 14 statements and that the Jenkins instance boundary has six. The prior assistant described hidden screenshots as showing the policy attached to `p3-terraform`, but those images are unavailable in the supplied copy and the author’s text does not independently confirm attachment. Neither saved policy JSON was compared line by line with its review copy; `AccessDenied` (AWS blocked the read for this identity) prevented the `p3-terraform` role’s attachment-list lookup. The two local candidates remain review copies. The UI port-forwarding policy remains unapplied. The cost gate and secret rotation are open.

**Bootstrap and teardown:** JCasC (Jenkins Configuration as Code, a plugin that applies settings from YAML) configures the controller. Its boot checks and agent-secret handoff remain untested. Jenkins-only teardown is planned by turning `enable_jenkins` off and confirming the plan removes only Jenkins resources; a full ephemeral destroy would also remove the app and NAT and needs separate approval. The conversation reports that the untracked teardown helper was deleted. The current documentation and candidate changes are not committed.

**Cost note:** the conversation reports about `$0.50` as the incremental two-instance compute floor and a `$2` planning target with an 8-hour stop rule. These are not a current quote or an approved automatic stop; NAT data, storage, other app costs, billing, and credit coverage are not verified.

**Other recorded risks:** Terraform state differs from its preserved backup; some Sonar findings remain accepted; prior-account cleanup and charges are unknown. Full evidence is in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), reusable details in [NOTES.md](NOTES.md), and Jenkins decisions in the [design record](docs/decisions/new-account-deployment-design.md). No current billing/credit check or monthly budget is recorded.

## Next safe step

Review the two local policy candidates and compare them with the saved policy JSON and `p3-terraform` attachment record before relying on the reported IAM state; the supplied conversation does not contain an inspectable read-back. Then complete the cost gate and one-time password rotation before a separately approved Terraform plan. For every Terraform command, first confirm `assumed-role/p3-terraform` in the same WSL shell and privately verify the intended account. No Terraform plan/apply, Jenkins runtime check, or additional IAM action is authorized by this documentation update. The automatic Build and Test demonstration after deployment trigger #3 remains pending separately.

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
- [ ] Repository cleanup is complete and Git status is clean. Documentation and policy-candidate changes remain uncommitted; the `vprofile-src` submodule’s internal state is unknown.

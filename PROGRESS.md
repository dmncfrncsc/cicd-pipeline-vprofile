# Project 3 session handoff

**Updated 2026-11-09.** This handoff uses the supplied conversation and repository evidence; no live AWS, Jenkins, GitHub Actions, SonarQube Cloud, or billing check was performed. The parent-folder guidance files were available locally; their adoption in Claude Project Knowledge is unverified. The local checkout is on `main` at `f80ae10`, matching `origin/main`; `PROGRESS.md` already had an unstaged edit at the start of this update, and the inaccessible submodule's internal status remains unverified.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds an approved CI/CD path. The repository owner did not author VProfile.

A resolved-plugin inventory is Jenkins' list of installed plugins after it selects requested plugins and their dependencies; the captured versions are recorded in [NOTES.md](NOTES.md).

**Active phase:** Documentation is aligned to the revised artifact acceptance scope. The portfolio interview guide is complete and stored in the shared parent folder; it is not implementation evidence. The artifact and documentation criteria are complete; repository cleanup and a clean Git status remain pending.

## Current status

**Delivery, quality, and artifact evidence (reported; details in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md)):** Both platforms have recorded successful deployments and same-app failure recovery using the shared build script and Ansible playbook; this meets the flow and recovery criteria. Both pipelines upload a locally built WAR to private versioned S3, then deploy the local copy; neither reads a WAR back from S3. Fifteen versions and a root-console download were reported on 2026-11-07, but no named-version, least-privilege retrieval was demonstrated. A 2026-11-09 author-supplied CLI result reports `p3-terraform` was denied `s3:ListBucketVersions`; it was not independently queried here. JaCoCo was run once locally against the instructor-provided app tests, not CI/CD code. The bootstrap-bucket `terraform:S6258` finding is recorded as Accepted, not fixed. Jenkins 2.580.2 was reported with no core advisory among the displayed notices; the plugin inventory was not opened.

Detailed boot, SSM, Terraform, IAM, submodule, validation, and cleanup evidence is in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) and [NOTES.md](NOTES.md). These are dated reports, not a live check of current AWS, Jenkins, GitHub, or billing state.

## Next safe step

The artifact criterion is closed against the revised scope: private versioned storage and non-root pipeline upload, with deployment from the local build; non-root retrieval of a named version was not demonstrated. Documentation alignment is complete. Repository cleanup and a clean Git status remain pending; this documentation-only update leaves four modified, unstaged files, and no files were staged or committed. The cost, cleanup, and ownership item is complete to the evidence scope recorded below and in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md): the reports are bounded and are not a claim of zero account-wide charges or exhaustive inventory. The author plans a separate recheck of the three prior-account secrets on or after 2026-11-10; that follow-up is not a Project 3 completion blocker. Keep the two quarantined state files outside Git until the recovery window ends. This handoff does not authorize AWS or Git state changes.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow, not the similarly named SSO `p3-terraform` profile, which was reported to target the prior account. Exported credentials in shell environment variables can override profile selection; use a clean shell when switching identities. A failed plan or a partial resource count is not an actionable plan.
- Keep account IDs, credentials, and WAR contents out of the public repository and workflow logs. Preserve attribution; do not copy the course application into this repository or publish a WAR. Public pull-request workflows stay build/test only. The repository's `Jenkinsfile` defines its pipeline; do not inspect or reuse the instructor's Jenkinsfile or course provisioning scripts.
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
- [CI parity and quality review](docs/ci-parity-and-quality-review.md): side-by-side flow and quality-check evidence
- [Decision records](docs/decisions/): [bootstrap backend](docs/decisions/terraform-bootstrap-s3-backend.md), [new-account design](docs/decisions/new-account-deployment-design.md), and [Jenkins plugin resolution](docs/decisions/jenkins-plugin-resolution.md)
- Claude Project Knowledge copies of PROGRESS.md and PROGRESS-HISTORY.md predate the 2026-10-23 updates; refresh them only with separate explicit authorization.

## Definition of Done

- [x] Architecture, tools, course coverage, costs, and security decisions are documented and approved before implementation.
- [x] CI build and tests run with recorded verification; GitHub Actions Run #1 and later trigger evidence are recorded.
- [x] The same build and deployment flow runs from GitHub Actions and Jenkins, each with recorded verification. Both use the shared build script and Ansible playbook; successful deployments and same-app failure recovery are recorded.
- [x] The WAR never appears in a public artifact, release, or log.
- [x] Quality checks are justified, with outcomes and limits recorded. This includes the accepted `terraform:S6258` finding and the one-off JaCoCo result; neither is described as a fix or CI coverage.
- [x] Source-use risk stance is documented; the course-provided application and WAR are not distributed publicly.
- [x] A versioned artifact is stored in the approved private store and uploaded by the non-root pipeline roles; deployment uses the locally built WAR. Non-root retrieval of a named version was not demonstrated. The 2026-11-07 root-console download does not satisfy the original criterion. Closed against this revised scope; the gap is a documented limitation.
- [x] Deployment to the approved target and health behavior are verified through the reported deployment runs and health checks.
- [x] Failure and rollback behavior is meaningfully demonstrated by the forced-failure path, same-app restoration, and post-restore checks.
- [x] Credentials and permissions are handled safely; the evidence and review scope are recorded in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- [x] Costs, cleanup, and cross-project ownership are documented and verified to the recorded scope: the 2026-11-06 billing screenshot reported October net USD 0 and a November estimate of USD 0; the Jenkins test teardown reported 24 resources destroyed and empty Terraform state plus bounded EC2/NAT/EIP/EBS queries in `us-east-1`; prior-account inventory and cleanup reads are recorded with their limits; and Project 3 state/resources are documented as separate from Projects 1 and 2. These are dated, author-supplied checks, not a current exhaustive inventory or a guarantee of zero charges. The author's on-or-after 2026-11-10 secret recheck is a separate follow-up.
- [x] README, NOTES, PROGRESS, and justified design documents match the reported work and its evidence limits; artifact retrieval is explicitly documented as unproven and outside the revised acceptance criterion (aligned 2026-11-09).
- [ ] Repository cleanup is complete and Git status is clean. Local `main` at `f80ae10` matched `origin/main` before this documentation update; four documentation files are now modified and unstaged, and the inaccessible submodule's internal status remains unverified.

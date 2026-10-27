# Project 3 session handoff

**Updated 2026-10-27.** Local Git shows `main`, `origin/main`, and `HEAD` at `a13155c`. Author-supplied terminal output reports PR #107 merged and local `main` fast-forwarded to that commit; no live GitHub check was made. Before these documentation edits, status with submodules ignored showed `main` aligned with `origin/main` and `scripts/teardown-ephemeral.sh` untracked. Regular status failed because Git could not access `vprofile-src`'s Git metadata, so its state is unknown. This handoff uses the supplied conversation and Terraform output, not live AWS checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** continue project completion after the 2026-10-27 rollback and teardown checkpoint. The conversation reports a successful one-go destroy and limited cleanup reads. Jenkins J1 (controller plus separate agent) is the accepted planning baseline; placement and a disposable controller are now selected for planning, and implementation remains unapproved. The accepted 8-hour planning limit was not a required wait or automatic shutdown timer.

## Current status

**Repository:** Local refs show `main`, `origin/main`, and `HEAD` at `a13155c`; author-supplied terminal output reports this followed PR #107's merge and local fast-forward. No live GitHub check was made. Before these documentation edits, status with submodules ignored showed no tracked changes and one untracked file, `scripts/teardown-ephemeral.sh`. A regular status attempt failed because the submodule Git metadata was inaccessible; `vprofile-src` state is unknown.

**Deployment and rollback (conversation-reported):** The supplied run summaries report a normal dispatch on `f6bad49` succeeded, the forced-failure dispatch on `f6bad49` restored the app and passed the `/`, `/users`, and database-user checks, and the final normal dispatch succeeded with 10 database users. Its pasted Ansible recap is `ok=24 changed=10 unreachable=0 failed=0 skipped=2 rescued=0 ignored=0`; its commit header was not supplied, so the same commit across all three runs is not confirmed. The forced-failure summary reports `failed=1 rescued=1` and a deliberate final failure. This demonstrates same-app rollback control flow, not recovery to a different build or rollback of database changes. Run evidence was not independently reopened. The `/users` retry fix from PR #103 has now been exercised in a host run, but the output does not show whether a retry was needed. Login, real-user behavior, search, and app-level RabbitMQ/Memcached use remain unverified.

**IAM and teardown (conversation-reported):** The three workflow runs exercised Ansible over SSM without a repeated `TerminateSession` error; this supports that path for those runs, not a full IAM or effective-permissions review. The first 14-resource destroy stopped at a 403 for `ec2:DisassociateAddress`; a destroy-only plan and apply then released the remaining unattached EIP. A later test showed that policy Version 4's unconditioned `network-interface/*` statement still did not resolve the 403. After the author selected and reported saving Version 5 with `ec2:DisassociateAddress` on `Resource: "*"` conditioned on `aws:RequestedRegion = us-east-1`, one plain `terraform destroy` reported `Destroy complete! Resources: 14 destroyed.` The author-supplied follow-up reported empty Terraform state, `[]` for the EIP, pending/available NAT gateway, active-instance, and available-volume queries in `us-east-1`, and an AWS-variable count of 0. The selected policy read-back reported Version 5 as Default and attached to `p3-terraform`; it did not show the full saved JSON, the 14-statement count, or removal of the old Sid. One successful run supports the one-go path but does not prove the original denial's cause or repeat reliability. These are supplied outputs and screenshot descriptions, not live checks. The policy was reported at 5 of 5 versions; another policy edit requires deleting an older version first. Root sign-out was reported. Billing, credits, other Regions, and other resource types were not checked.

**Open follow-up:** Jenkins J1 remains planning-only. Option A (hosts in the existing ephemeral root behind a default-off variable) and a disposable controller rebuilt by Ansible are accepted for planning. The selected install strategy is a signed official LTS apt repository with exact Jenkins and required plugin pins, but neither the LTS package version nor plugin versions are set. The controller Java requirement, agent-process Java, Maven JDK compatibility, and package-site NAT reachability need resolution. The agent IAM/session option (item 3) and credential placement (item 4) remain undecided; extra security-group permission coverage and expanded-stack teardown are unverified. Redo the cost gate with current NAT rates and credit coverage before implementation. Source-use permission, login/real-user/search behavior, and app-level RabbitMQ/Memcached use remain open. Billing and credit coverage were not checked. The cause of the earlier `DisassociateAddress` 403 remains unknown, and the one-go destroy has succeeded only once. The policy is at its reported five-version limit. An untracked `scripts/teardown-ephemeral.sh` was syntax-checked but never run; the successful plain destroy means it is not needed for the tested teardown path. Checking older public workflow logs for account-ID output remains low priority; Deploy #6 deletion was reported. The `ansible/deploy.yml` header still says “draft, not yet run”; the stale code comment was not changed here.

**Cost note:** The 8-hour figure was an accepted planning ceiling for the proposed session, not a required wait, an automatic stop, current pricing, or a guaranteed dollar cap. The supplied conversation reports that the three runs were performed in one sitting and teardown began about 23 minutes after apply; actual charges and credit coverage were not checked. The N. Virginia NAT rate and package-site connectivity remain unknown.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

Decide item 3: one new agent instance role with an unverified `session/i-*` pattern, or an agent role that assumes a second deploy role with a fixed `p3-deploy-jenkins` session name. Then decide item 4 credential placement. Keep the exact Jenkins LTS/plugin versions, Java compatibility questions, package NAT reachability, and current cost gate open for review before implementation. No owner session, code, Terraform plan, AWS resource, or billable work is approved by these planning choices. The supplied teardown output reports empty state and empty results for four resource queries in `us-east-1`, but it does not establish billing, credit coverage, or the state of other Regions and resource types. No eight-hour wait is required.

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
- [ ] Repository cleanup is complete and Git status is clean (the latest destroy and limited resource checks were reported successful; documentation changes are uncommitted and the untracked teardown helper remains outside the reviewed documentation set).

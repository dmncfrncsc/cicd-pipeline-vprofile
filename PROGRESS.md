# Project 3 session handoff

**Updated 2026-10-27.** Local Git shows `main`, `origin/main`, and `HEAD` at `f5a84db`. Author-supplied terminal output reports PR #108 merged and local `main` fast-forwarded from `a13155c`; no live GitHub check was made. Before these documentation edits, status with submodules ignored showed `main` aligned with `origin/main` and `scripts/teardown-ephemeral.sh` untracked. Regular status failed because Git could not access `vprofile-src`'s Git metadata, so its state is unknown. This handoff uses the supplied conversation and Terraform output, not live AWS checks. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** continue project completion after the reported 2026-10-27 rollback and teardown. Jenkins J1 (controller plus separate agent), Option 2 for agent AWS access, Option A for controller credentials, and `p3-terraform` for Jenkins UI port forwarding are planning choices only. The proposed user-session policy is not applied; implementation remains unapproved.

## Current status

**Repository:** Local refs show `main`, `origin/main`, and `HEAD` at `f5a84db`; author-supplied terminal output reports this followed PR #108's merge and local fast-forward. No live GitHub check was made. Before these documentation edits, status with submodules ignored showed no tracked changes and one untracked file, `scripts/teardown-ephemeral.sh`. A regular status attempt failed because the submodule Git metadata was inaccessible; `vprofile-src` state is unknown.

**Deployment and rollback (conversation-reported):** three dispatches reportedly ended normal green, forced-failure red after successful same-app restore, and normal green. This supports same-app file restore, not recovery to a different build or database rollback; Run 3's commit was not supplied. The `/users` retry fix ran, but the output does not show whether a retry occurred. Login, real-user behavior, search, and app-level RabbitMQ/Memcached use remain unverified. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the run details and evidence limits.

**IAM and teardown (conversation-reported):** one plain `terraform destroy` reportedly removed 14 resources, followed by empty state and four empty resource queries in `us-east-1`. Policy Version 5 of 5 was reported Default and attached to `p3-terraform`, but full policy text and effective permissions were not checked. One success does not explain the earlier 403 or prove repeat reliability. Billing, credits, other Regions, and other resource types remain unchecked. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for the teardown sequence and evidence limits.

**Open follow-up:** the author chose `p3-terraform` as the user identity for SSM port forwarding to the private Jenkins UI, using the tight `${aws:userid}-*` session scope. Proposed statements are preserved in [the review-only policy copy](docs/drafts/jenkins-ui-ssm-port-forwarding-policy-review.md); they are not applied. A local instance-role draft includes `SsmAgentCore`, but that does not verify the saved role or network path. GPT-reported tables describe Jenkins 2.580.1, Java 21/25, and an inbound WebSocket agent, but their source rows/URLs were hidden in the pasted copy; exact pins and current prices remain open. Also unresolved: NAT versus SSM endpoints, the WSL Session Manager plugin, agent/admin bootstrap credentials, plugin dependency pins, submodule visibility, agent trust behavior, and cost/credit coverage. Keep untrusted code off the deploy-capable agent. The automatic Build and Test demonstration after deployment trigger #3 remains separate follow-up. The teardown helper was never run; its keep/delete decision is open. See the history and design record for detail.

**Cost note:** the accepted 8-hour figure was a planning ceiling, not a required wait, automatic stop, quote, or dollar cap. The conversation reports teardown began about 23 minutes after apply; actual charges and credit coverage were not checked. See history for the reported timing.

**Other recorded risks:** Terraform state differs from its preserved backup; some Sonar findings remain accepted; prior-account cleanup and charges are unknown. Full evidence is in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), reusable details in [NOTES.md](NOTES.md), and Jenkins decisions in the [design record](docs/decisions/new-account-deployment-design.md). No current billing/credit check or monthly budget is recorded.

## Next safe step

Compare the `p3-terraform` policy draft with the [review-only port-forwarding proposal](docs/drafts/jenkins-ui-ssm-port-forwarding-policy-review.md), then determine whether the controller can reach SSM through NAT or VPC endpoints. The local `SsmAgentCore` draft is not proof of saved AWS permissions or network reachability. Obtain the complete GPT research tables and URLs before choosing Jenkins versions or closing the cost gate; the pasted copy omitted them. Keep policy changes, builds, implementation, owner sessions, Terraform plans, AWS resources, and spending unapproved. The automatic Build and Test demonstration after deployment trigger #3 remains pending separately.

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
- [ ] Repository cleanup is complete and Git status is clean (the latest destroy and limited resource checks were reported successful; documentation changes are uncommitted and the untracked teardown helper remains outside the reviewed documentation set).

# Project 3 session handoff

**Updated 2026-10-27.** At the start of this documentation update, local Git showed `main`, `origin/main`, and `HEAD` at `f6bad49` (PR #104). The top-level tree was clean when the inaccessible `vprofile-src` submodule was excluded. This handoff uses the supplied conversation and Terraform output; no AWS or GitHub service was checked live. See [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md) for evidence and limits.

## Objective and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. The repository owner did not author VProfile, and source-use permission remains unresolved.

**Active phase:** recover and verify the partial Terraform teardown before further deployment work. The normal / forced-failure / normal dispatch sequence has run according to the supplied conversation. The previously accepted 8-hour planning limit was not a required wait or automatic shutdown timer.

## Current status

**Repository:** Local Git showed `main`, `origin/main`, and `HEAD` at `f6bad49` before this documentation update. Status succeeds only with the submodule excluded; Windows could not access its Git metadata, so the submodule's state is unknown. The supplied conversation reports PR #104 checks passed and its branch was deleted; no live GitHub check was made.

**Deployment and rollback (conversation-reported):** The supplied run summaries report a normal dispatch on `f6bad49` succeeded, the forced-failure dispatch on `f6bad49` restored the app and passed the `/`, `/users`, and database-user checks, and the final normal dispatch succeeded with 10 database users. Its pasted Ansible recap is `ok=24 changed=10 unreachable=0 failed=0 skipped=2 rescued=0 ignored=0`; its commit header was not supplied, so the same commit across all three runs is not confirmed. The forced-failure summary reports `failed=1 rescued=1` and a deliberate final failure. This demonstrates same-app rollback control flow, not recovery to a different build or rollback of database changes. Run evidence was not independently reopened. The `/users` retry fix from PR #103 has now been exercised in a host run, but the output does not show whether a retry was needed. Login, real-user behavior, search, and app-level RabbitMQ/Memcached use remain unverified.

**IAM and teardown (author-supplied):** The conversation reports a fresh `p3-new` session with `assumed-role/p3-terraform` and a private account match. The deploy-role policy correction was reported applied. The three workflow runs exercised Ansible over SSM without a repeated `TerminateSession` error, supporting that path for these runs; this is not a full IAM-policy or effective-permissions review. The destroy plan listed 14 resources. Its apply removed the instance, NAT gateway, VPC, routes, subnets, and security-group resources, then failed while disassociating the NAT EIP: `ec2:DisassociateAddress` returned 403 because no identity-based policy allowed it. No `Destroy complete!`, state listing, EIP read-back, or final resource verification was supplied. The EIP's remaining association/allocation and Terraform state are unresolved; do not mark teardown complete.

**Open follow-up:** Resolve the residual EIP/state and verify no ephemeral resources remain; the current `DisassociateAddress` denial shows the teardown permission gap persists despite the reported policy update. The NAT interface tag condition and effective authorization cause are still unknown. No billing, credit, or post-failure credential-clear check was supplied. Jenkins/J1-vs-J2, source-use permission, login/real-user/search behavior, and app-level RabbitMQ/Memcached use remain open. Checking older public workflow logs for account-ID output remains low priority; Deploy #6 deletion was reported. The `ansible/deploy.yml` header still says “draft, not yet run”; the stale code comment was not changed here.

**Cost note:** The 8-hour figure was an accepted planning ceiling for the proposed session, not a required wait, an automatic stop, current pricing, or a guaranteed dollar cap. The supplied conversation reports that the three runs were performed in one sitting and teardown began about 23 minutes after apply; actual charges and credit coverage were not checked. The N. Virginia NAT rate and package-site connectivity remain unknown.

**Other recorded risks:** Terraform state serial/lineage differs from the preserved backup; full saved IAM policies and effective permissions remain unchecked; some Sonar findings are accepted rather than fixed; prior-account resources and charges are unknown, with cleanup deferred. Detailed evidence, caveats, and decisions are in [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [design record](docs/decisions/new-account-deployment-design.md). The cost gate used planning estimates only; no billing/credit check or monthly budget is recorded.

## Next safe step

Finish teardown recovery in `infra/ephemeral`. In the same WSL shell, load a fresh documented `p3-new` session and verify `assumed-role/p3-terraform` plus the intended account privately before every Terraform command. Inspect the current Terraform state and remaining EIP/resource status, then create and review a fresh destroy-only plan for whatever remains; do not run a normal plan against partially destroyed state or apply an unreviewed plan. The earlier teardown authorization covered the stack teardown, but it does not authorize changing IAM or starting another run. If EIP disassociation is still denied, stop and resolve the narrowly scoped permission issue through the appropriate approval path. Verify empty ephemeral state and no remaining EIP, NAT gateway, instance, or volume, then clear the temporary AWS variables. No eight-hour wait is required. After cleanup, decide whether to add functional backend checks and choose Jenkins J1 versus J2.

## Safety boundaries

- Before every Terraform command, in the same WSL shell confirm the identity is `assumed-role/p3-terraform` and privately verify the intended account. Use the documented `p3-new` flow; `default` and `p3-readonly` are reported to target the prior account. Clear/count AWS variables after the session; the transcript's zero count applied before a later MFA session was loaded.
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
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean (the latest destroy failed at EIP disassociation; residual resources and state remain unverified, and this documentation update still needs the user's Git/PR workflow).

# Project 3 session handoff

**Updated 2026-10-22.** This is the current operational handoff, based on local repository evidence and author-supplied terminal output and console screenshots. AWS and GitHub service state has not been freshly checked; the identity and policy evidence is historical and reported.

## Project and current phase

Project 3 builds and tests the instructor-provided VProfile application, then adds a CI/CD path to an approved AWS target. VProfile is not authored by this repository's owner; source-use permission remains unresolved.

**Phase 1 — GitHub Actions build/test: complete in recorded CI evidence.** The workflow has recorded successful `pull_request`, `push` to `main`, and `workflow_dispatch` runs. It has no AWS access and keeps the WAR on the runner. The evidence is historical; this audit did not query GitHub or rerun CI. See [historical milestones](PROGRESS-HISTORY.md), [NOTES.md](NOTES.md), and the [workflow](.github/workflows/build-test.yml).

**Most recent recorded infrastructure milestone:** On 2026-10-21, the new-account six-resource state-bucket bootstrap was applied, read back, and migrated to S3. A subsequent plan reportedly refreshed all six resources and returned `No changes`. The current local backend configuration names `p3-vprofile-tfstate-r5w8n2`, key `bootstrap/terraform.tfstate`, region `us-east-1`, SSE enabled, and `use_lockfile = true`. Those AWS results are recorded terminal evidence, not a fresh live check in this review. The implementation commit is in local merge commit `5f2238f` (PR #49).

The earlier account's bootstrap state and D1 buckets were also implemented according to dated records, but that account is paused. No application stack, new-account WAR bucket, Ansible transfer bucket, deployment, health check, or rollback has been recorded as created or verified in the new account. Jenkins is required before project completion; its setup option remains undecided.

## Completed work and evidence limits

- The public repository contains the author's pipeline, infrastructure, and documentation; VProfile is pinned as submodule `vprofile-src`. The recorded source pin is `9f22748`; its continued reachability is uncertain. No public WAR distribution is allowed while source-use permission is unresolved.
- At the time of the 2026-10-21 documentation audit, the local instruction pair was Master Prompt v4.7 and Project 3 Instructions v3.7. The audit treated v4.8/v3.8 as proposals and prepared a coordinated v4.9/v3.9 proposal pair. No version was confirmed as active in the project settings at that time.
- CI build/test evidence covers all three triggers and the `protect-main` required check. Detailed run limits and the PR #2 failure-path experiment are preserved in [NOTES.md](NOTES.md) and [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md).
- New-account Terraform sign-in, state-bucket settings, migration, and post-migration plan are recorded from terminal output dated 2026-10-21. The state migration changed `serial` and `lineage`; normalizing those fields reportedly made the remaining content match the preserved backup. A reported local SHA-256/metadata comparison of `infra/bootstrap/terraform.tfstate.backup` and a separate outside-repository copy found them byte-identical (9,174 bytes, serial 7, same lineage). The exact command and second copy's path were not retained. The comparison did not include live S3. The cause of the remote metadata change remains unknown. Do not replace state by hand, reuse the applied plan, or run `terraform destroy` as a diagnostic.
- Author-supplied terminal output records a successful `p3-new` assumed-role identity check in WSL. Before any role session was loaded, plain `aws sts get-caller-identity` returned the IAM user in the `default` profile in both Git Bash and WSL. Git Bash had only a `default` profile, so use WSL for Terraform. The author reported that `default` and `p3-readonly` map to the old account and `p3-new` to the new account; the `p3-readonly` SSO token was expired. After exported credentials were cleared, three IAM reads returned `NoSuchEntity`; no caller-identity output was captured after cleanup. This is consistent with a default identity in another account, but does not prove it. Only the 2026-10-21 record verified fallback after `unset`.
- Author-supplied console screenshots and saved-policy text report one customer inline `p3-state-bucket` policy, no managed policies, and no permissions boundary. The policy text is scoped to the state bucket, allows bucket-policy deletion, denies bucket deletion, and omits several version/tag actions. These are historical reports, not a fresh effective-permissions check. On 2026-10-22 the author explicitly accepted, as a temporary risk to revisit in the D2 IAM review, that the role can weaken or remove the HTTPS-only bucket policy; this is a risk acceptance, not a fix or a verified control. IAM actions and organization-level controls were not tested. See the [bootstrap backend decision record](docs/decisions/terraform-bootstrap-s3-backend.md) and [NOTES.md](NOTES.md).
- Account plan and credits were reported before the final IAM/bootstrap work; charge eligibility is unknown. No monthly budget was created. Prior-account credit/support history and all pricing assumptions are historical, not current quotes.
- **Credit and account-wide safeguard (author-directed):** In the prior account, creating an AWS Organization was followed by credit expiry, and AWS Support's first reply (identified as AI-generated) linked the events; causation is not established, and the effect of any Organization action on this account's credits is unknown. As a precaution, do not create or join an Organization, and do not open or use the Organizations console even to inspect organization-level controls. Avoid account-wide actions that could expire credits; stop and ask before changing any account-wide setting. Known actions to avoid include Organization or Control Tower setup, Identity Center changes, account-plan changes or closure, Partner Network membership, Professional Services contracts, Enterprise Agreements, Skill Builder Team subscriptions, and HIPAA/SEC designations; this list is not exhaustive. Do not distribute a WAR publicly; a private artifact copy remains subject to separate design, cost, and implementation approval.

## Recorded scope, sequence, and approvals

The recorded deployment sequence is: complete a new-account AWS design and cost review, then add GitHub Actions deployment to the approved target; Jenkins is a later required phase intended to run the same flow against that target. This sequence does not approve deployment, spending, or resource creation. Prior-account Phase D design approvals do not automatically apply to the new account. No new-account application design, cost gate, or implementation gate is complete.

Keep Phase 1 pull-request workflows build/test only with no AWS access. Do not derive the pipeline from the instructor's `Jenkinsfile` without a focused need and approval. Do not reuse Project 1 or 2 infrastructure, state, buckets, secrets, or networks without an approved design and verified ownership. Never put credentials, AWS account IDs, VProfile source contents, or a WAR in this public repository or public workflow logs.

## Open issues and safety boundaries

- Resolve the unexplained `serial`/`lineage` change for both account migrations before any state replacement, restore, or destructive action. Keep the local and separate backups outside Git.
- Before any Terraform command, verify `aws sts get-caller-identity` in the same WSL shell and stop unless it identifies the intended new-account `assumed-role/p3-terraform` session. The 2026-10-22 terminal evidence showed `p3-new` could assume that role. Git Bash had only a `default` profile; the author reported that `default` and `p3-readonly` target the old account, and the `p3-readonly` token was expired. Do not use those profiles for Project 3. No caller-identity output was captured after exported credentials were cleared; three IAM reads returned `NoSuchEntity`, which is consistent with but does not prove a fallback identity in another account. Only the 2026-10-21 record verified fallback after `unset`.
- The author-supplied saved `p3-state-bucket` policy and console screenshots report no managed policies and no permissions boundary, but do not establish full effective permissions. The assumed role's attempts to read its own IAM attachments and role details returned `AccessDenied`; the saved-policy text is the available policy evidence. `s3:UntagResource`, `s3:ListBucketVersions`, `s3:GetObjectVersion`, and `s3:DeleteObjectVersion` are absent from that text; bucket-policy deletion and the explicit bucket-deletion deny were not exercised, nor was a real HTTP-denial request. Organization-level controls were not checked because the author directed that the Organizations console not be opened.
- The HTTPS-only bucket-policy exposure is an accepted temporary risk as of 2026-10-22; revisit it in the D2 IAM review, or sooner if the role is used beyond the state bucket or a second person gets access.
- New-account D2/D3 scope, IAM/OIDC design, WAR and Ansible bucket design, S3 logging, root-volume encryption, instance sizing, Ansible execution, health behavior, rollback, and credit applicability remain open or unverified. Recheck N. Virginia prices at the cost gate.
- The old account's support case and resource cleanup remain unresolved. Do not infer that a historical inventory proves current live resources or charges.
- Documentation maintenance does not authorize implementation, AWS mutations, spending, deployment, Git state changes, or external settings changes. Apply the separate approvals in the active instructions.

## Next safe action

The live state metadata comparison remains unresolved. If you choose to resume it, explicitly authorize a read-only AWS check, verify caller identity in the same shell, then compare the live new-account S3 state's `serial` and `lineage` with the preserved pre-migration backup without displaying state contents. The local backup copies already matched each other; that does not resolve the live-state metadata change. Stop if the account or role is unexpected or the comparison is ambiguous. After resolving or explicitly deferring this question, prepare a new-account design and cost gate for the next infrastructure phase; do not treat the old-account D2/D3 plan as approval.

**Prerequisites:** a valid MFA-backed new-account role session, backups retained outside the repository, and permission for any AWS reads required by the active instructions. Do not apply, destroy, migrate, or replace state as part of this handoff step.

## Related references and future interview guide

- [Historical milestones and dated evidence](PROGRESS-HISTORY.md)
- [Technical learning reference](NOTES.md)
- [Repository overview](README.md).
- [Decision records](docs/decisions/), including the consolidated [bootstrap backend decision record](docs/decisions/terraform-bootstrap-s3-backend.md).

Defer the interview guide until the implementation is sufficiently complete and verified. Keep factual explanations in NOTES and decision records in the meantime; a later guide should separate tutorial-provided, pre-existing, generated, and AI-assisted work from the author's verified contributions and use only evidence-backed results.

## Repository checkpoint recorded during the documentation audit

Read-only checks during the 2026-10-21 documentation audit found branch `main` at `5f2238f` (`Merge pull request #49 ...`); the locally stored `origin/main` ref pointed to the same commit. At the start of that audit, `git status --short --branch --ignore-submodules=all` showed a pre-existing unstaged `PROGRESS.md` edit and five untracked review copies, with no staged changes. The ordinary status command failed because Git could not access `.git/modules/vprofile-src`; full submodule status and remote parity could not be verified. No AWS or GitHub service checks were made. This is the audit's starting checkpoint, not the current working-tree status.

## Definition of Done

- [ ] Architecture, tools, course coverage, costs, and security decisions are documented and approved before implementation.
- [x] CI build and tests have recorded successful verification (Run #1 and later trigger evidence).
- [ ] The same build and deployment flow runs from GitHub Actions and Jenkins, each with recorded verification.
- [x] No public WAR artifact, release, or workflow-log distribution is recorded; continue enforcing this constraint.
- [ ] Quality checks are justified, with outcomes and limits recorded.
- [x] Source-use permission is established, or the accepted-risk stance is documented; the WAR is never distributed publicly. Permission itself remains unresolved.
- [ ] A versioned artifact is retrievable from the approved private store, only after the required design, cost, and implementation approvals.
- [ ] Deployment to the approved target and health behavior are verified.
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated; the forced CI error path turned CI red, but the original zero-test assertion and rollback behavior remain unverified.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean.

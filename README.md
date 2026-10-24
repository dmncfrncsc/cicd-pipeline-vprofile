# cicd-pipeline-vprofile

Project 3 of an AWS DevOps portfolio: build and test the instructor-provided VProfile application, then develop an approved CI/CD path around it. VProfile is a course reference application, not software authored by this repository's owner.

## Status

**Recorded CI/configuration evidence (through 2026-10-07; not freshly rechecked):** Phase 1 GitHub Actions build/test has successful recorded runs for pull requests, pushes to `main`, and manual dispatch. The workflow uses the pinned `vprofile-src` submodule and `scripts/build.sh`; pull-request runs have no AWS credentials and cannot deploy. The `protect-main` ruleset was recorded as requiring the `build-test` check.

**Recorded evidence from terminal output (2026-10-21; not freshly rechecked):** New-account IAM access and a Terraform S3 state-bucket bootstrap were reported in place. The bootstrap state was migrated to S3, and a later plan reported no changes. This is setup state only: no application infrastructure, WAR or Ansible bucket, or deployment had been recorded as created or verified in the new account by that date. See `PROGRESS.md` for the evidence limits.

**Owner-session update (author-reported, 2026-10-23–24):** a separately approved session reportedly created two named permissions boundaries and attached the `p3-terraform-durable` inline policy to `p3-terraform`. The author later reported signing out. The saved AWS policy text was not compared line by line with repository drafts.

**Durable bucket code (merged 2026-10-24):** PR #66 added Terraform for the planned private WAR bucket and an Ansible transfer bucket. Author-supplied WSL output reports a reviewed plan of 6 to add, 0 to change, 0 to destroy. The code has not been applied; no application bucket creation or deployment is recorded. HTTPS-only policies and bucket settings must be applied and read back in a separately approved owner session before either bucket is used.

**Not done:** creating the durable buckets through Terraform, Jenkins, application deployment, health checks, and rollback testing. Jenkins is required before project completion, but the setup option is still open. The new-account cost gate was accepted on 2026-10-22 using existing planning estimates; regional-rate, credit, budget, and technical limits remain open. Terraform apply and spending are not approved. See [PROGRESS.md](PROGRESS.md) and the [new-account design decision](docs/decisions/new-account-deployment-design.md).

## Scope and next phases

- Keep Phase 1 limited to build and test. Do not add AWS access to public pull-request workflows.
- Recorded deployment order: complete AWS design and cost review, then add GitHub Actions deployment to the approved target, subject to separate design, cost, and implementation approval. Jenkins is a required later phase for the same build/deployment flow and target; this sequence does not authorize resource creation or deployment.
- Keep Project 3 infrastructure, Terraform state, buckets, and credentials separate from the other portfolio projects unless a specific reuse design is approved and verified.

## Source and artifact handling

The pinned `vprofile-src` submodule contains the instructor-provided VProfile source. Attribution is preserved. Source-use permission remains unresolved; this is an accepted project risk, not a permission grant. A built WAR must not be published in this repository, a public release, or workflow logs. Use private artifact storage only after the applicable approvals and required policy/settings read-back.

The submodule points to `dmncfrncsc/vprofile-project`; its relationship to `hkhcoder/vprofile-project` is reported but has not been independently verified. No license file was found in the checked source, and course terms were not checked.

## Project documents

- `PROGRESS.md` — current state, evidence, open issues, and next step.
- `PROGRESS-HISTORY.md` — dated milestones and evidence supporting the current handoff.
- `NOTES.md` — detailed technical explanations and learning reference.
- `docs/decisions/` — durable records for meaningful design choices.

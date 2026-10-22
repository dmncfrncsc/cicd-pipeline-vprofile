# cicd-pipeline-vprofile

Project 3 of an AWS DevOps portfolio: build and test the instructor-provided VProfile application, then develop an approved CI/CD path around it. VProfile is a course reference application, not software authored by this repository's owner.

## Status

**Recorded CI/configuration evidence (through 2026-10-07; not freshly rechecked):** Phase 1 GitHub Actions build/test has successful recorded runs for pull requests, pushes to `main`, and manual dispatch. The workflow uses the pinned `vprofile-src` submodule and `scripts/build.sh`; pull-request runs have no AWS credentials and cannot deploy. The `protect-main` ruleset was recorded as requiring the `build-test` check.

**Recorded evidence from terminal output (2026-10-21; not freshly rechecked):** New-account IAM access and a Terraform S3 state-bucket bootstrap were reported in place. The bootstrap state was migrated to S3, and a later plan reported no changes. This is setup state only: no application infrastructure, WAR or Ansible bucket, or deployment had been recorded as created or verified in the new account by that date. See `PROGRESS.md` for the evidence limits.

**Not done:** Jenkins, application deployment, health checks, and rollback testing. Jenkins is required before project completion, but the setup option is still open. No new-account application deployment design, cost gate, or implementation approval has been completed.

## Scope and next phases

- Keep Phase 1 limited to build and test. Do not add AWS access to public pull-request workflows.
- Recorded deployment order: complete AWS design and cost review, then add GitHub Actions deployment to the approved target, subject to separate design, cost, and implementation approval. Jenkins is a required later phase for the same build/deployment flow and target; this sequence does not authorize resource creation or deployment.
- Keep Project 3 infrastructure, Terraform state, buckets, and credentials separate from the other portfolio projects unless a specific reuse design is approved and verified.

## Source and artifact handling

The pinned `vprofile-src` submodule contains the instructor-provided VProfile source. Attribution is preserved. Source-use permission remains unresolved; this is an accepted project risk, not a permission grant. A built WAR must not be published in this repository, a public release, or workflow logs. Current records say the new account has no WAR storage bucket; private artifact storage is only a future option after the applicable design, cost, and implementation approvals.

The submodule points to `dmncfrncsc/vprofile-project`; its relationship to `hkhcoder/vprofile-project` is reported but has not been independently verified. No license file was found in the checked source, and course terms were not checked.

## Project documents

- `PROGRESS.md` — current state, evidence, open issues, and next step.
- `PROGRESS-HISTORY.md` — dated milestones and evidence supporting the current handoff.
- `NOTES.md` — detailed technical explanations and learning reference.
- `docs/decisions/` — durable records for meaningful design choices.

# cicd-pipeline-vprofile

Project 3 of an AWS DevOps portfolio: build and test the instructor-provided VProfile application, then develop an approved CI/CD path around it. VProfile is a course reference application, not software authored by this repository's owner.

## Status

**Recorded CI/configuration evidence (through 2026-10-07; not freshly rechecked):** Phase 1 GitHub Actions build/test has successful recorded runs for pull requests, pushes to `main`, and manual dispatch. The workflow uses the pinned `vprofile-src` submodule and `scripts/build.sh`; pull-request runs have no AWS credentials and cannot deploy. The `protect-main` ruleset was recorded as requiring the `build-test` check.

**Recorded evidence from terminal output (2026-10-21; not freshly rechecked):** New-account IAM access and a Terraform S3 state-bucket bootstrap were reported in place. The bootstrap state was migrated to S3, and a later plan reported no changes. This is setup state only: no application infrastructure, WAR or Ansible bucket, or deployment had been recorded as created or verified in the new account by that date. See `PROGRESS.md` for the evidence limits.

**Owner-session update (author-reported, 2026-10-23–24):** session 1 reportedly created two named permissions boundaries and attached the `p3-terraform-durable` inline IAM policy to `p3-terraform`; the author later reported signing out. Those session-1 IAM policy contents were not compared line by line with repository drafts. Session 2 status is summarized below.

**Durable buckets (apply and owner-session read-backs reported 2026-10-24):** PR #66 added Terraform for the private WAR bucket and Ansible transfer bucket. Author-supplied terminal output reports that applying a freshly reviewed saved plan added six resources. AWS CLI output reports SSE-S3 on both buckets and WAR versioning with a 30-day noncurrent-version lifecycle. The earlier CLI transfer-versioning read returned no status; a later console screenshot reports Versioning Disabled for the named transfer bucket. In session 2, the WAR bucket's four Block Public Access settings were reported On and its HTTPS-only policy was reported saved with text matching the draft. For the transfer bucket, the author reports all four Block Public Access settings On, but the described screenshot crop did not show the bucket name. A console success banner was reported after saving its HTTPS-only policy, and the pasted JSON matched the draft and named the transfer bucket; the record does not establish a separate fresh read-back from the saved policy. The author reports privately confirming the intended account and signing out; the account ID remains redacted, so those claims are not independently verifiable here. No bucket use or application deployment is reported. See [PROGRESS.md](PROGRESS.md) for current limits and the next safe step.

**Remaining:** the `production` Environment is reported restricted to `main`; a temporary workflow reported the expected OIDC subject, and one non-main run was blocked. The author chose a review-only AWS trust using `aud` and exact `sub` only, which relies on the GitHub Environment branch rule; administrator bypass remains enabled. No AWS deploy role or trust policy is applied. The networking and compute IAM candidates have had a text-only review; two security-group-rule statements were added to the review-only draft by author-confirmed planning choice. The policies remain unattached and untested, and NAT-only versus an S3 gateway endpoint is undecided. The next step is to finish Gate A preparation and request separate approval before any policy attachment or AWS session. Jenkins, application deployment, health checks, and rollback testing remain; Jenkins is required before project completion, but the setup option is open. The new-account cost gate was accepted on 2026-10-22 using planning estimates; live billing and credit status, regional rates, budget, and technical limits remain unchecked. This documentation update does not authorize further AWS actions. See [PROGRESS.md](PROGRESS.md) and the [new-account design decision](docs/decisions/new-account-deployment-design.md).

## Scope and next phases

- Keep Phase 1 limited to build and test. Do not add AWS access to public pull-request workflows.
- Recorded deployment order: complete AWS design and cost review, then add GitHub Actions deployment to the approved target, subject to separate design, cost, and implementation approval. Jenkins is a required later phase for the same build/deployment flow and target; this sequence does not authorize resource creation or deployment.
- Keep Project 3 infrastructure, Terraform state, buckets, and credentials separate from the other portfolio projects unless a specific reuse design is approved and verified.

## Source and artifact handling

The pinned `vprofile-src` submodule contains the instructor-provided VProfile source. Attribution is preserved. Source-use permission remains unresolved; this is an accepted project risk, not a permission grant. A built WAR must not be published in this repository, a public release, or workflow logs. Use private artifact storage only after the applicable approvals and required policy/settings read-back; the author reports that neither durable bucket has been used yet.

The submodule points to `dmncfrncsc/vprofile-project`; its relationship to `hkhcoder/vprofile-project` is reported but has not been independently verified. No license file was found in the checked source, and course terms were not checked.

## Project documents

- `PROGRESS.md` — current state, evidence, open issues, and next step.
- `PROGRESS-HISTORY.md` — dated milestones and evidence supporting the current handoff.
- `NOTES.md` — detailed technical explanations and learning reference.
- `docs/decisions/` — durable records for meaningful design choices.

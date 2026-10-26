# cicd-pipeline-vprofile

Project 3 of an AWS DevOps portfolio: build and test the instructor-provided VProfile application, then develop an approved CI/CD path around it. VProfile is a course reference application, not software authored by this repository's owner.

## Status

**Recorded CI/configuration evidence (through 2026-10-07; not freshly rechecked):** Phase 1 GitHub Actions build/test has successful recorded runs for pull requests, pushes to `main`, and manual dispatch. The workflow uses the pinned `vprofile-src` submodule and `scripts/build.sh`; pull-request runs have no AWS credentials and cannot deploy. The `protect-main` ruleset was recorded as requiring the `build-test` check.

**Recorded evidence from terminal output (2026-10-21; not freshly rechecked):** New-account IAM access and a Terraform S3 state-bucket bootstrap were reported in place. The bootstrap state was migrated to S3, and a later plan reported no changes. This is setup state only: no application infrastructure, WAR or Ansible bucket, or deployment had been recorded as created or verified in the new account by that date. See `PROGRESS.md` for the evidence limits.

**Owner-session update (author-reported, 2026-10-23–24):** session 1 reportedly created two named permissions boundaries and attached the `p3-terraform-durable` inline IAM policy to `p3-terraform`; the author later reported signing out. Those session-1 IAM policy contents were not compared line by line with repository drafts. Session 2 status is summarized below.

**Durable buckets (apply and owner-session read-backs reported 2026-10-24; status at that checkpoint):** PR #66 added Terraform for the private WAR bucket and Ansible transfer bucket. Author-supplied terminal output reports that applying a freshly reviewed saved plan added six resources. AWS CLI output reports SSE-S3 on both buckets and WAR versioning with a 30-day noncurrent-version lifecycle. The earlier CLI transfer-versioning read returned no status; a later console screenshot reports Versioning Disabled for the named transfer bucket. In session 2, the WAR bucket's four Block Public Access settings were reported On and its HTTPS-only policy was reported saved with text matching the draft. For the transfer bucket, the author reports all four Block Public Access settings On, but the described screenshot crop did not show the bucket name. A console success banner was reported after saving its HTTPS-only policy, and the pasted JSON matched the draft and named the transfer bucket; the record does not establish a separate fresh read-back from the saved policy. The author reports privately confirming the intended account and signing out; the account ID remains redacted, so those claims are not independently verifiable here. At this checkpoint, no bucket use or application deployment had been reported; the later deployment checkpoint below reports WAR-bucket use.

**Ephemeral test and cleanup (author-reported, 2026-10-24):** a single `t3.large` instance reportedly ran in a private subnet with no public IPv4, an encrypted, tagged 20 GiB gp3 root volume, and an available NAT gateway. The instance later reported `Online` in SSM after a compute-policy update. The first destroy removed 13 of 14 resources, then failed because `ec2:DisassociateAddress` was denied. A refreshed EIP-only plan then released the address. Final terminal checks reported empty ephemeral Terraform state and no EIPs, pending/available NAT gateways, or active EC2 instances in `us-east-1`. These are author-supplied results, not a fresh live check; billing and credits were not checked. SSM registration was tested, but no interactive SSM session, package/S3 access, Ansible transfer, or application deployment was reported.

**Deployment checkpoint (reported in the supplied conversation; run evidence not independently reviewed):** Deploy #5 on commit `4d8c178` was reported green after fixes in PRs #89–#92. The successful run exercised the GitHub Actions-to-AWS path, SSM playbook, application checks, and a database-user nonempty gate. The exact row count is not present in the supplied run output. The temporary stack was then torn down; commands for Terraform state, EIPs, NAT gateways, instances, and available volumes returned no entries, and the WSL AWS-variable count was 0. Billing and credits were not checked. Local Git is on `main` at `4d8c178`; the current Git status was clean before this documentation update.

**Remaining:** Jenkins is required and undecided between J1 and J2; rollback is not implemented or tested. The repeated `ec2:DisassociateAddress` denial required a refreshed EIP-only destroy and remains a teardown-policy gap. Login and a real user session, Elasticsearch/search behavior, exact health response codes, billing, and credit status remain unknown. No live service check was performed for this update. See [PROGRESS.md](PROGRESS.md), [PROGRESS-HISTORY.md](PROGRESS-HISTORY.md), and the [new-account design decision](docs/decisions/new-account-deployment-design.md).

## Scope and next phases

- Keep Phase 1 limited to build and test. Do not add AWS access to public pull-request workflows.
- The manual GitHub Actions workflow has one reported successful end-to-end run on an ephemeral target; it was torn down afterward. Rollback remains open. Jenkins is a required later phase for the same build/deployment flow and target.
- Keep Project 3 infrastructure, Terraform state, buckets, and credentials separate from the other portfolio projects unless a specific reuse design is approved and verified.

## Source and artifact handling

The pinned `vprofile-src` submodule contains the instructor-provided VProfile source. Attribution is preserved. Source-use permission remains unresolved; this is an accepted project risk, not a permission grant. A built WAR must not be published in this repository, a public release, or workflow logs. Use private artifact storage only after the applicable approvals and required policy/settings read-back; the author reports that neither durable bucket has been used yet.

The submodule points to `dmncfrncsc/vprofile-project`; its relationship to `hkhcoder/vprofile-project` is reported but has not been independently verified. No license file was found in the checked source, and course terms were not checked.

## Project documents

- `PROGRESS.md` — current state, evidence, open issues, and next step.
- `PROGRESS-HISTORY.md` — dated milestones and evidence supporting the current handoff.
- `NOTES.md` — detailed technical explanations and learning reference.
- `docs/decisions/` — durable records for meaningful design choices.

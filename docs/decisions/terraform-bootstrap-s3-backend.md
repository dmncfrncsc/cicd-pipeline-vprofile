# Decision: Store Project 3 bootstrap state in its S3 state bucket

**Canonical decision record updated 2026-10-22.** This record combines the historical prior-account migration evidence with the new-account backend decision. AWS resource and role details are summarized from recorded terminal output and author-supplied policy text and console screenshots; they are not current live checks.

**Status:** Chosen and migrated in the new account according to recorded 2026-10-21 terminal evidence. An author-supplied read-only comparison dated 2026-10-22 confirmed that live S3 metadata differs from the preserved backup; it did not compare state contents or explain the cause. The role's effective permissions remain unverified. Its ability to remove the HTTPS-only bucket policy was explicitly accepted by the author on 2026-10-22 as a temporary risk (see "HTTPS-only bucket policy: accepted temporary risk" below).

## Problem and constraints

The bootstrap Terraform configuration creates the bucket that will hold its state, so it must first run with local state. Keeping that state local long term ties the bucket's record to one computer. Project 3 moved to a new AWS account; its state and permissions must stay separate from Projects 1 and 2. State files and backups must stay out of the public repository.

## Decision

After creating the new account's dedicated state bucket with local state, migrate the bootstrap state to that bucket at `bootstrap/terraform.tfstate`, in `us-east-1`, using SSE-S3 and Terraform S3 lock files (`use_lockfile = true`). The recorded new-account bucket is `p3-vprofile-tfstate-r5w8n2`. The local backend configuration contains that bucket, key, region, encryption flag, and lock-file setting. Recorded read-backs showed versioning, public-access blocking, AES256 encryption, a 30-day noncurrent-version lifecycle rule, and an HTTPS-only bucket policy.

This decision applies only to Project 3's new-account bootstrap. It does not authorize state sharing, infrastructure reuse, deployment, or bucket deletion.

## Account-wide actions and credit safeguard

The author directed that the AWS Organizations console not be opened or used, including for read-only inspection of organization-level controls. In the prior account, creating an Organization was followed by credit expiry, and AWS Support's first reply, identified as AI-generated, linked the events. This does not establish causation or the effect of any Organizations action on credits in this account. As a precaution, avoid account-wide actions that could expire credits and stop for explicit direction before changing any account-wide setting. Known actions to avoid include Organization or Control Tower setup, Identity Center changes, account-plan changes or closure, Partner Network membership, Professional Services contracts, Enterprise Agreements, Skill Builder Team subscriptions, and HIPAA/SEC designations; this list is not exhaustive.

## Alternatives and trade-offs

- **Keep local state:** fewer remote permissions and settings, but the state remains tied to one computer and is easier to lose or misplace.
- **Use Project 3's dedicated S3 bucket:** selected after the bucket exists. It enables a shared remote state path and lock file, but adds IAM and bucket-policy complexity and makes the bucket hold its own creation record.
- **Use another bucket:** not selected. A second bucket was not needed or separately costed.

Versioning can help recover an earlier object version, but the lifecycle rule removes noncurrent versions after 30 days. The explicit `s3:DeleteBucket` deny in the candidate role policy would protect only requests made by that role, not every AWS principal. S3 storage and requests may still cost money; no hourly-billed application resource was created by the migration.

## Evidence and limits

### New account — 2026-10-21

- Terraform v1.16.5 and AWS provider v6.69.1 initialized the bootstrap configuration. A saved plan showed six resources to add; the separately approved apply completed with six added, none changed, and none destroyed.
- Read-backs showed versioning enabled, all four S3 public-access settings enabled, AES256 encryption, the 30-day noncurrent-version lifecycle rule, and the `DenyInsecureTransport` bucket policy.
- The local state was serial 7 and 9,174 bytes. A separate backup matched its SHA-256 fingerprint before migration, and the S3 destination prefix was empty. `terraform init -migrate-state` reported successful migration.
- After migration, S3 contained the state object and no lock object remained after unlock. A normal plan refreshed all six resources and reported `No changes`. After normalizing only `serial` and `lineage`, the local and S3 state fingerprints matched. The S3 state serial became 1 and its lineage changed; the cause is not known.
- Keep the local backup and the separate outside-repository backup. The local state file is now empty. Do not push backups, replace active state by hand, reuse the applied plan, or run `terraform destroy` as a diagnostic.
- A reported local SHA-256/metadata comparison reviewed on 2026-10-22 compared `infra/bootstrap/terraform.tfstate.backup` with a separate outside-repository backup and found the copies byte-for-byte identical, each 9,174 bytes with serial 7 and the same lineage. The exact command and second copy's path were not retained; state contents were not printed. This checks backup-to-backup consistency only; it does not compare either copy with live S3 or explain the changed remote metadata.
- A later author-supplied WSL check on 2026-10-22 found live S3 serial 1 and a different lineage from the preserved repository backup (serial 7). It printed only metadata, did not compare state contents, and did not identify why the metadata changed. See [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md) for the recorded values.

### Prior account — 2026-10-17 (historical; not the current backend)

- The prior-account bootstrap state was migrated to bucket `p3-vprofile-tfstate-x4b8t3`, key `bootstrap/terraform.tfstate`, using the `p3-terraform` profile. Before migration, the local state and separate backup had matching SHA-256 fingerprints; the recorded S3 destination prefix was empty.
- The recorded S3 object was 9,682 bytes. Its state serial changed from 9 to 1 and its lineage changed; after normalizing those two fields, the remaining content matched the backup. A later plan refreshed all six resources and reported `No changes`. The cause of the metadata change remained unresolved.
- A version listing returned `AccessDenied` for `s3:ListBucketVersions`; the number of stored versions was unknown. Terraform output did not provide an API-by-API IAM trace.
- The migration was recorded as a process deviation: `terraform init -migrate-state` began before separate explicit approval had been given. Answering Terraform's copy prompt with `yes` was not that approval. The decision record was preserved as historical context, not as a current-account instruction.
- That account is paused and is not the current backend. Its bucket, policy, cost, and live state were not rechecked on 2026-10-22.

### Permission and verification limits

Author-supplied console screenshots and saved-policy text report one customer inline policy, `p3-state-bucket`, no managed policies, and (by author report) no permissions boundary. The screenshot showed only part of the policy. The text is scoped to the state bucket, allows `s3:PutBucketPolicy` and `s3:DeleteBucketPolicy`, and explicitly denies `s3:DeleteBucket`. It does not include `s3:UntagResource`, `s3:ListBucketVersions`, `s3:GetObjectVersion`, or `s3:DeleteObjectVersion`. These are reported findings, not an independent live AWS read.

**Separate public-access-block permission is unresolved.** The supplied `p3-state-bucket` policy text includes `s3:PutBucketPublicAccessBlock`, and the current local bootstrap configuration declares `aws_s3_bucket_public_access_block.state` in [`infra/bootstrap/main.tf`](../../infra/bootstrap/main.tf). The 2026-10-22 risk acceptance covers only the HTTPS-only bucket-policy exposure; no separate acceptance was recorded for the role changing the public-access block. The account-level S3 settings were not checked. The later planning decision to omit this permission for the two durable application buckets does not apply to the bootstrap state bucket.

Allowing `s3:DeleteBucketPolicy` lets the role remove the HTTPS-only bucket policy as well as manage it; on 2026-10-22 the author explicitly accepted that exposure as a temporary risk (see the next subsection). Policy deletion, the explicit bucket-deletion deny, version listing or restore access, and a real HTTP-denial request were not tested. Organization-level controls were not checked because the author directed that the Organizations console not be opened. The role's full effective permissions therefore remain unverified, and the successful migration and plan are not an API-by-API IAM trace. No apply, restore, or rollback test was performed after the new-account S3 migration.

### HTTPS-only bucket policy: accepted temporary risk (2026-10-22)

**Status:** Explicitly accepted by the author on 2026-10-22 as a temporary risk, to be revisited in the D2 IAM review. This is a risk acceptance, not a fix and not a verified control.

**Problem.** The reported `p3-state-bucket` policy text lets `p3-terraform` call `s3:PutBucketPolicy` and `s3:DeleteBucketPolicy` on the state bucket. A session of that role can therefore weaken or remove the `DenyInsecureTransport` policy that rejects plain-HTTP requests.

**Why both actions are kept.** Terraform needs `PutBucketPolicy` to create or update the policy; the prior account's first apply failed when it was missing. It needs `DeleteBucketPolicy` to remove the policy cleanly if the resource is replaced or destroyed. Removing only Delete would add little protection, because Put can overwrite the policy with a permissive one, and it could make Terraform cleanup fail.

**Alternatives considered.**
- Accept and document (chosen for now).
- Remove only `s3:DeleteBucketPolicy`: little real protection, with a cleanup cost.
- Remove both Put and Delete: the role could no longer weaken the policy, but Terraform could not manage it either, so changes would need a second, more privileged identity.
- A separate, rarely used role for policy changes: keeps Terraform management possible while separating duties, at the cost of more IAM to design and test. Deferred to the D2 IAM review.
- An organization-level guardrail: not considered, because the safeguard prohibits using AWS Organizations. Other account-wide actions would need the author's approval first.

**Mitigations and their limits.**
- MFA applies when the role is assumed. It does not protect a session that has already been issued.
- A later `terraform plan` can show a missing or changed policy as drift. It detects the change after the fact; it does not prevent the change or block HTTP requests.
- The saved policy text is scoped to the state bucket, but the role's effective permissions remain unverified, so the role is not confirmed to be bucket-only.

**Revisit if** the role is used for anything beyond the state bucket, a second person gets access, or the project moves toward production-like use. Policy deletion, a real HTTP-denial request, and the `s3:DeleteBucket` deny remain untested.

## Interview explanation

“I created the Project 3 state bucket first with local state, then migrated the small bootstrap state to S3 with locking so later Terraform runs could use the configured shared backend. I kept a separate backup because both the prior-account and new-account migrations changed Terraform's serial and lineage unexpectedly. The normalized content matched and the new-account plan reported no changes, but the cause of those metadata changes and some IAM actions remain unverified, so I recorded those limits instead of claiming the migration was fully explained. I also recorded that the Terraform role can remove the HTTPS-only bucket policy, which I accepted as a temporary risk to revisit in the IAM review instead of claiming it was controlled.”

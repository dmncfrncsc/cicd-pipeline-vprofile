# Decision: Store bootstrap state in the S3 state bucket

**Date:** 2026-10-17

**Status:** Chosen and migrated; a state-metadata change remains unexplained.

## Problem and constraints

The bootstrap configuration initially kept its Terraform state in a local file. That is simple, but ties Terraform's record of the state bucket to one computer and makes the file harder to use safely from another authorized environment. The S3 bucket already existed, had versioning and encryption enabled, and had a dedicated state key planned. The bootstrap must first create the bucket locally because the bucket cannot hold state before it exists.

## Decision and reason

Move the bootstrap state to the existing bucket `p3-vprofile-tfstate-x4b8t3`, at `bootstrap/terraform.tfstate`, using the `p3-terraform` profile, SSE-S3 encryption, and `use_lockfile = true`. This tests the remote backend, lock, and Job 2 object permissions before Phase D, while the managed stack is still only the six-resource bucket bootstrap.

## Alternatives considered

- **Keep local state:** fewer settings and permissions, but state stays tied to one computer and can be lost with that local copy.
- **Use the existing S3 bucket:** selected because it was already dedicated to Terraform state; adds bucket access and locking permissions and makes the bucket hold its own creation record.
- **Create another state bucket:** not needed because the existing bucket was already the approved dedicated state bucket; this option was not separately costed or tested.

## Trade-offs and safeguards

The bucket is the storage for its own state, so deletion of the bucket would remove access to that record. The explicit `s3:DeleteBucket` deny protects only the `p3-terraform` role, not every principal. A separate backup was kept outside the repository, and Terraform's local `terraform.tfstate.backup` remained available. S3 versioning preserves older object versions, but the configured lifecycle rule expires noncurrent versions after 30 days. The migration added one small object and did not create an hourly-billed resource; S3 storage and requests can still have charges. State can contain sensitive information, so neither the state nor its backups belong in the public repository.

## Evidence and limits

Reported from Ubuntu WSL terminal output on 2026-10-17:

- Before migration, the local state and separate backup had matching SHA-256 fingerprints; the destination prefix was empty in a single-page S3 listing.
- `terraform init -migrate-state` prompted to copy the local state; `yes` was entered, and Terraform reported that the S3 backend was configured and initialization succeeded.
- A later `terraform plan` refreshed all six resources and reported “No changes.” A read-only listing showed one 9,682-byte state object and no `.tflock` object after the plan.
- The local `terraform.tfstate` became 0 bytes. The 9,682-byte local `terraform.tfstate.backup` matched the separate backup. The S3 copy had the same bytes except `serial` (9 to 1) and `lineage` (a new value); replacing only those fields made the fingerprints match. Why Terraform changed them is unresolved.
- The migration command ran before separate explicit approval had been stated in chat. The CLI `yes` answered Terraform's copy prompt; it was not the separate approval gate. This is recorded as a process deviation, not as approval.

The plan and listing show the S3 backend was usable for the tested operation. Terraform output did not identify individual S3 API calls, so the evidence does not prove an action-by-action IAM trace. The migration wrote the state object, so the backend role had effective permission to write the state key (`s3:PutObject`; an inference, not an API trace). A version listing returned `AccessDenied` for `s3:ListBucketVersions`, which `p3-terraform` was not granted, so the number of state versions in S3 is unknown. No `terraform apply` followed this migration, and no state restore or rollback test was performed. Keep the external backup and do not manually overwrite or force-push state while the lineage change is unexplained.

## Interview explanation

“I moved the small bootstrap's state to the existing S3 bucket before Phase D so I could test remote state, locking, and the scoped object permissions early. Local state would have been simpler, but it would tie Terraform's record to one machine. The trade-off is that the bucket stores the record of its own creation, so I kept an external backup and added a deny on `s3:DeleteBucket` for the Terraform role. That deny stops only that role, not every AWS principal. The migration and a no-change plan succeeded, but the state's lineage and serial changed unexpectedly, so I recorded that as unresolved instead of claiming the migration was fully explained.”

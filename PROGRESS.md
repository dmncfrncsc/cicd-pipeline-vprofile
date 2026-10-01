# PROGRESS.md — `cicd-pipeline-vprofile` (Project 3)

Public handoff record, last updated 2026-10-01. It holds decisions, state, and next steps only. Account-specific details are kept in a private record, and anything not stated here as done has not been done.

## Project and phase

- **Goal:** design and build a CI/CD pipeline that builds the instructor-provided VProfile reference application and delivers it to an approved Terraform-managed AWS target.
- **Portfolio position:** Project 3 of 5 in an AWS portfolio.
- **Current phase:** Phase 1 (GitHub Actions CI, build/test only), step 1.
- **Done and verified:** public GitHub repository created and cloned locally; `main` is the default branch on GitHub; README, PROGRESS, NOTES, and `.gitignore` committed and pushed. The public-safe files were scanned for account-specific details before the push.
- **Not done:** no submodule, workflow, build, or AWS resources for this project yet.
- **Next step:** add the pinned VProfile source submodule (the author's fork), verify a local Maven build and tests, then create the Actions workflow.

## Decisions (approved 2026-10-01)

- **Pipeline:** designed from scratch. The instructor's upstream `Jenkinsfile` is reference material only and is not copied.
- **Application:** VProfile is instructor-provided, not written by the repository author.
- **Scope and order:** Phase 1 GitHub Actions, then Phase 2 Jenkins (required before the project is complete). Both are meant to run the same build and deployment flow against the same target, one tool at a time. Within Phase 1, build/test comes first and AWS deployment is added only after its design and cost gate.
- **Repository:** public; holds only the author's pipeline code, infrastructure code, and documentation. No credentials, account identifiers, built WARs, or VProfile source contents in the repository or workflow logs. The VProfile source is planned as a pinned submodule of the author's fork.
- **Branches:** `main` plus short-lived pull-request branches. Named status checks become required on `main` after the first successful workflow run; no reviewer requirement.
- **Triggers:** `pull_request`, `push` to `main`, and `workflow_dispatch`. Phase 1 runs are build/test only with no AWS access.
- **Infrastructure ownership:** Project 3 has its own infrastructure and Terraform state. It does not reuse resources, state, buckets, or secrets from Projects 1 and 2 unless a reuse design is written and approved.

## Source-use status

Permission to redistribute the VProfile source is **unresolved**. No license file was found in the reference clone, and the upstream and course terms were not checked. The author chose to proceed on an interim stance as an accepted risk. This is not permission. Mitigations: attribution is preserved, only the author's own work is in this repository, and a built WAR is never published (private storage only, no public artifact, release, or log). A built WAR will not be distributed publicly unless permission is established.

## Open design choices (proposals, not approved)

- AWS deployment path: artifact bucket, GitHub OIDC role scope, Terraform state backend and locking, deployment target, SSM access path, and full cost review are all unapproved. No AWS deployment work starts before this gate.
- Jenkins layout for Phase 2: controller plus separate agent, or a single instance. To be chosen before Phase 2.
- Nexus and SonarQube: undecided pending course-material and cost review.
- Webhook and load balancer for Jenkins: deferred.
- Planned but unimplemented behavior: artifact version from CI build number plus source commit, a health check after deployment, and rollback on failure.

## Definition of Done

- [ ] Architecture, tools, course coverage, costs, and security decisions documented and approved before implementation.
- [ ] CI build and tests run with recorded verification.
- [ ] The same build and deployment flow runs from GitHub Actions and from Jenkins, each with recorded verification.
- [ ] The WAR never appears in a public artifact, release, or log.
- [ ] Quality checks are justified, with outcomes and limits recorded.
- [ ] A versioned artifact is retrievable from the approved store.
- [ ] Deployment to the approved target and health behavior are verified.
- [ ] Failure and rollback behavior is tested or meaningfully demonstrated.
- [ ] Credentials and permissions are handled safely.
- [ ] Costs, cleanup, and cross-project ownership are documented and verified.
- [ ] README, NOTES, PROGRESS, and justified design documents match verified work.
- [ ] Repository cleanup is complete and Git status is clean.

# PROGRESS.md — `cicd-pipeline-vprofile` (Project 3)

Public handoff record, last updated 2026-10-01. It holds decisions, state, and next steps only. Account-specific details are kept in a private record, and anything not stated here as done has not been done.

## Project and phase

- **Goal:** design and build a CI/CD pipeline that builds the instructor-provided VProfile reference application and delivers it to an approved Terraform-managed AWS target.
- **Portfolio position:** Project 3 of 5 in an AWS portfolio.
- **Current phase:** Phase 1 (GitHub Actions CI, build/test only); repository setup is complete, and VProfile source-revision selection/local validation is next.
- **Done and verified:** public GitHub repository created and cloned locally; `main` is the default branch on GitHub; README, PROGRESS, NOTES, and `.gitignore` committed and pushed. The public-safe files were scanned for account-specific details before the push.
- **Not done:** no VProfile revision is selected or pinned in Project 3; no submodule, workflow, or Project 3 AWS resources exist. A scratch `mvn clean package` produced `target/vprofile-v2.war` but ran 0 tests: the tests are JUnit 4 and only the JUnit 5 engine is on the classpath. In the scratch copy only, adding `junit-vintage-engine` 5.10.0 made `mvn test` run 9 tests with 0 failures, errors, or skips. The Project 3 repository was not changed for this.
- **Next step:** identify the reference clone by running `git rev-parse origin/local origin/atom` in the two upstream-pointing clones (expect `9f22748...` and `036431a...`); then run a read-only `gh` check for any VProfile fork under the author's account; decide the submodule URL (fork or upstream); inspect `pom.xml` at the chosen commit (insertion anchor, line endings); design the shared script and zero-test guard. Ask approval before any command that changes files or adds the submodule. No revision is selected or pinned. Keep Project 3 operations in its separate clone.

## Decisions (approved 2026-10-01)

- **Pipeline:** designed from scratch. Do not inspect, consult, copy, or derive the design from the instructor's `Jenkinsfile` or other instructor pipeline file. If one becomes necessary to answer a specific unresolved question, explain why and get the user's approval before accessing it.
- **Application:** VProfile is instructor-provided, not written by the repository author.
- **Scope and order:** Phase 1 GitHub Actions, then Phase 2 Jenkins (required before the project is complete). Both are meant to run the same build and deployment flow against the same target, one tool at a time. Within Phase 1, build/test comes first and AWS deployment is added only after its design and cost gate.
- **Repository:** public; holds only the author's pipeline code, infrastructure code, and documentation. No credentials, account identifiers, built WARs, or VProfile source contents in the repository or workflow logs. The VProfile source is planned as a pinned submodule; whether it points at the author's fork or at the upstream repository is open (see Open design choices).
- **Branches:** `main` plus short-lived pull-request branches. Named status checks become required on `main` after the first successful workflow run; no reviewer requirement.
- **Triggers:** `pull_request`, `push` to `main`, and `workflow_dispatch`. Phase 1 runs are build/test only with no AWS access.
- **Zero-test fix location (approved 2026-10-01):** Option B. Pin an unmodified VProfile commit and apply the `junit-vintage-engine` fix at build time from one shared script in this repository, called by both GitHub Actions and Jenkins. The build also fails if Maven reports `Tests run: 0`. This adds no new public change to the VProfile source. Not yet verified: the script's insertion anchor in `pom.xml`, `pom.xml` line endings, and `bash` availability on both platforms. The added `<dependency>` block is a recorded modification of VProfile's `pom.xml`, with attribution.
- **Infrastructure ownership:** Project 3 has its own infrastructure and Terraform state. It does not reuse resources, state, buckets, or secrets from Projects 1 and 2 unless a reuse design is written and approved.

## Source-use status

Permission to redistribute the VProfile source is **unresolved**. No license file was found in the reference clone, and the upstream and course terms were not checked. The author chose to proceed on an interim stance as an accepted risk. This is not permission. Mitigations: attribution is preserved, only the author's own work is in this repository, and a built WAR is never published (private storage only, no public artifact, release, or log). A built WAR will not be distributed publicly unless permission is established. Option B avoids publishing a modified copy of the VProfile source; this reduces exposure but is not permission.

## Open design choices (proposals, not approved)

- **VProfile submodule revision:** not selected. Verified tips in the reference clone on 2026-10-01: `origin/local` `9f22748bf6d3b6c14e0bc98a5db1c7167f1b509e`, `origin/atom` `036431a6552ab20e7d21d7638f5e5412f7735104` (earlier reported `bcb4eb5`/`4a43339` did not match). The scratch copy's `pom.xml` and `src` match `origin/local` apart from line endings; its exact commit cannot be proven (plain copy, no `.git`). Tested with Maven 3.9.16, Java 17.0.19, Surefire 3.5.4; `origin/local`'s POM targets Java 17. Neither branch references the deleted logo in `src` or `pom.xml`. `origin/atom` was not built or tested. The fix location is decided (Option B). Select and pin only after the reference clone is re-identified (see next bullet) and `pom.xml` at the chosen commit is inspected.
- **Reference clone and submodule URL:** not verified. The scratch copy has no `.git`, so Git commands fail there. A search found local clones whose `origin` points at two upstream VProfile repositories; which one holds `origin/local` and `origin/atom` is not yet verified. No fork of VProfile under the author's account has been confirmed. Do not record a submodule URL until verified.
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

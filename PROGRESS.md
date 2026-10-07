# PROGRESS.md — `cicd-pipeline-vprofile` (Project 3)

Public handoff record, last updated 2026-10-07. It holds decisions, state, and next steps only. Account-specific details are kept in a private record, and anything not stated here as done has not been done.

## Project and phase

- **Goal:** design and build a CI/CD pipeline that builds the instructor-provided VProfile reference application and delivers it to an approved Terraform-managed AWS target.
- **Repository location and command context:** The Project 3 repository root is `cicd-pipeline-vprofile`; the pinned VProfile source is inside it at `vprofile-src/`. Before running project commands, use `git rev-parse --show-toplevel` to confirm the current Git root is the Project 3 repository, not the nested VProfile source repository. Use repository-relative paths in this public handoff record.
- **Portfolio position:** Project 3 of 5 in an AWS portfolio.
- **Current phase:** Phase 1 (GitHub Actions CI, build/test only). The VProfile source is pinned as a submodule in the local checkout. `scripts/build.sh` now exists in the local checkout and has run once; the GitHub Actions workflow has not been created. Phase 1 still has no AWS access.
- **Done and verified:** public GitHub repository created and cloned locally; `main` is the default branch on GitHub; README, PROGRESS, NOTES, and `.gitignore` committed and pushed. The public-safe files were scanned for account-specific details before the push.
- **Latest checkout check (terminal output pasted 2026-10-03):** the root repository was on `main`, two commits ahead of `origin/main`, with `NOTES.md` and `PROGRESS.md` modified. The `vprofile-src` submodule was at the recorded commit `9f22748bf6d3b6c14e0bc98a5db1c7167f1b509e`. On 2026-10-07, `git status -sb` showed `main` ahead of `origin/main` by 4 commits (verified from pasted output), so the local commits have not been pushed.
- **POM line endings (verified from pasted output and byte counts, 2026-10-07):** `git ls-files --eol` printed `i/lf w/crlf`: Git stores `vprofile-src/pom.xml` as LF, while the checked-out file is CRLF. Byte counts found 321 CR and 321 LF in the source POM, 0 CR and 321 LF in the scratch copy, and 0 CR and 321 LF in `build-work/pom.xml` after `sed -i`.
- **POM anchor (verified by a read-only local-file check, 2026-10-04):** `vprofile-src/pom.xml` contains one opening `<dependencies>` tag at line 30 and one closing `</dependencies>` tag at line 252. The earlier line 2/9 locations were inaccurate; line numbers may change if the pinned POM changes.
- **Local build checks (verified from pasted output, 2026-10-07):** `scripts/build.sh` exists (1,354 bytes, executable), and `bash -n` printed `syntax OK`. `.gitignore` ignores `build-work/`; `git status --short` listed `.gitignore`, `NOTES.md`, `PROGRESS.md`, and untracked `scripts/`. `build-work/mvn.log` records 9 tests with 0 failures, errors, or skips, and `BUILD SUCCESS`; `build-work/target/vprofile-v2.war` exists (83,278,692 bytes). `git -C vprofile-src status --short` printed nothing. The script exit code `0` was reported; its final `OK:` line was not shown.

- **Build-script learning (reported in chat, 2026-10-07):** The user reports answering a check after each of the eight script chunks; the output-channel and `[1-9][0-9]*` test-count checks were skipped, not confirmed. Earlier checks confirmed the `sed` closing-tag replacement, Maven `package`, why `pipefail` is used with `tee`, and why the script edits `build-work/pom.xml` instead of the pinned source. The user asked not to revisit the two skipped checks unless they ask.

- **Not done:** No GitHub Actions workflow or Linux CI/Jenkins build has been run. The local script run is evidenced by the Maven log and WAR file above, but the final `OK:` line was not shown and the failure paths have not been tested. The script and the `.gitignore` change were committed locally on 2026-10-07 as `c174211` (verified from `git log --oneline`). No push was run, so they are not on GitHub. The documentation changes were committed locally as `ffb8f68` (`docs: record first verified build and learning notes`) and are also not pushed. No Project 3 AWS resource creation or deployment is verified.

- **Cost check (reported in chat, 2026-10-03):** the summary says the check was read-only, found no hourly-billed resources running at that time, and made no AWS changes. Raw live output is not included here, so this is not a fresh or independently verified account inventory. Resource ownership was not established.
- **Next step:** The script and documentation commits (`c174211`, `ffb8f68`) are local only. Before any push, re-scan the public-safe files for account-specific details and get approval. The temporary POM scratch folder is outside the repository; remove it when its evidence is no longer needed. Then proceed with the Phase 1 GitHub Actions workflow that calls `scripts/build.sh` for build/test only, with no AWS access. The output-channel and test-count checks were skipped; do not quiz the user on them again unless asked. Source provenance remains open. No AWS work starts before its separate design and cost gate. The README still describes the submodule as planned; update it after reviewing the source pin and provenance.

## Decisions

- **Pipeline:** designed from scratch. Do not inspect, consult, copy, or derive the design from the instructor's `Jenkinsfile` or other instructor pipeline file. If one becomes necessary to answer a specific unresolved question, explain why and get the user's approval before accessing it.
- **Application:** VProfile is instructor-provided, not written by the repository author.
- **Scope and order:** Phase 1 GitHub Actions, then Phase 2 Jenkins (required before the project is complete). Both are meant to run the same build and deployment flow against the same target, one tool at a time. Within Phase 1, build/test comes first and AWS deployment is added only after its design and cost gate.
- **Repository:** public; holds the author's pipeline code, infrastructure code, and documentation, with VProfile referenced through a pinned submodule in the current local checkout. No credentials, account identifiers, built WARs, or VProfile source contents in workflow logs. The submodule URL points to the author's fork; source-use permission remains unresolved.
- **Branches:** `main` plus short-lived pull-request branches. Named status checks become required on `main` after the first successful workflow run; no reviewer requirement.
- **Triggers:** `pull_request`, `push` to `main`, and `workflow_dispatch`. Phase 1 runs are build/test only with no AWS access.
- **Zero-test fix location (approved 2026-10-01):** Option B. Pin an unmodified VProfile commit and apply the `junit-vintage-engine` fix at build time from one shared script in this repository, called by both GitHub Actions and Jenkins. The script fails the build unless Maven's log shows a positive `Tests run:` count. The local script run inserted the dependency into the copy, and the Maven log reported 9 tests with no failures, errors, or skips. GitHub Actions and Jenkins have not run it; Bash availability and behavior on those platforms remain unverified. When implemented, document the temporary POM modification with attribution and leave the pinned source unchanged.

- **Build script status:** `scripts/build.sh` was approved for saving on 2026-10-07 after the chunk-by-chunk review, saved locally, and run once. It was committed locally as `c174211` (`feat: add shared Maven build script`) on 2026-10-07 (verified from `git log --oneline`) and has not been pushed.
- **Build work folder (approved 2026-10-03):** use `build-work/` inside the repository and ignore it in `.gitignore`. The current `.gitignore` contains the `build-work/` entry.
- **Build-copy line endings (chosen 2026-10-07):** The user chose option 1: accept LF in the temporary `build-work/` copy. `sed -i` converts the copy from CRLF to LF; the pinned source remains CRLF, and the local Maven log shows the LF copy built successfully. This records the choice without changing the script.

- **Cost handling preference (stated 2026-10-03):** keep resources billed monthly and delete resources billed hourly. Monthly usage charges can still grow with consumption (for example, stored data), so flag material expected growth during cost review. The cost discussion in chat was account-level and did not verify ownership of the listed resources; it authorized no Project 3 resource reuse, and no AWS resources were changed in that exchange.
- **Infrastructure ownership:** Project 3 has its own infrastructure and Terraform state. It does not reuse resources, state, buckets, or secrets from Projects 1 and 2 unless a reuse design is written and approved.

## Source-use status

Permission to redistribute the VProfile source is **unresolved**. No license file was found in the reference clone, and the upstream and course terms were not checked. The author chose to proceed on an interim stance as an accepted risk. This is not permission. Mitigations: attribution is preserved, only the author's own work is in this repository, and a built WAR is never published (private storage only, no public artifact, release, or log). A built WAR will not be distributed publicly unless permission is established. Option B avoids publishing a modified copy of the VProfile source; this reduces exposure but is not permission.

## Open design choices (proposals, not approved)

- **VProfile source pin (local status; provenance pending):** The last recorded local status says Project 3 pins `vprofile-src` to `9f22748bf6d3b6c14e0bc98a5db1c7167f1b509e`; `.gitmodules` and the submodule remote point to `https://github.com/dmncfrncsc/vprofile-project.git`. This was previously recorded as the `origin/local` candidate, but no output from the proposed remote-branch or `gh` checks has been recorded. A read-only check on 2026-10-04 confirmed one opening dependencies tag at POM line 30 and one closing tag at line 252; provenance and branch assumptions remain unverified.

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

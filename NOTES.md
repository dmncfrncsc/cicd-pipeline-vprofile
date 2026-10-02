# NOTES.md — `cicd-pipeline-vprofile` (Project 3)

These are chronological learning notes, not a project-status log. `PROGRESS.md` owns current state, decisions, unresolved issues, and next steps. Entries below preserve concepts from Sessions 1–6 without repeating the full project handoff.

## 2026-09-29 — Session 1: CI/CD tools and scratch-build decision

**Jenkins** coordinates pipeline runs and records stage results/logs; in this project it can run the VProfile Maven build. A self-managed Jenkins machine costs compute while it runs and needs carefully scoped deployment credentials.

**Nexus** stores versioned build artifacts such as the VProfile WAR. It does not build or run the application; S3 is an alternative to compare.

The instructor `Jenkinsfile` is reference material, not the Project 3 design. Project 3 is to be designed from scratch so the pipeline stages, configuration, artifact versioning, and deployment choices are understood rather than copied.

The course covers Jenkins, GitHub Actions, and GitLab CI/CD. The exact collapsed lecture order and instructor repository layout were not verified and should not be guessed.

## 2026-09-29 — Session 2: Pipeline location and triggers

A pipeline definition can live with application source, or in a separate repository that fetches and pins source. The repository layout and trigger were still open at this learning checkpoint.

Common CI triggers include push, pull request, tag/release, and manual run. A trigger starts work; it does not by itself decide what code or deployment target is safe to use.

## 2026-09-29 — Session 3: Source checkouts and reuse

Projects 1 and 2 used a prebuilt VProfile WAR; Project 3 needs a reproducible checkout of Java source so it can build the WAR.

A Git submodule records a repository URL and a specific commit pointer. CI initializes the submodule to fetch that pinned source revision; changing it records a source update in the Project 3 repository.

A public fork or submodule does not itself establish permission to build or redistribute the source/artifact. Preserve provenance and attribution, and verify the source terms before public distribution.

## 2026-09-30 — Session 4: CI/CD planning concepts

The Jenkins controller coordinates jobs; an agent performs build steps. Hosted CI runners avoid operating a Jenkins machine, but do not automatically have network access to private EC2 targets.

Nexus stores versioned artifacts; SonarQube analyzes source quality. They serve different roles and need separate justification.

Polling checks for source changes on a schedule; a webhook sends an event when a change occurs. SSM port forwarding can provide controlled Jenkins UI access without public SSH; a webhook/ALB path needs separate ingress and cost review.

Terraform is planned for infrastructure and Ansible for machine/application configuration. S3 versioning and encryption are planned for remote Terraform state; the exact locking setting must be verified for the selected Terraform version.

IAM roles can supply AWS permissions to instances; Jenkins credentials can hold tool tokens. Do not commit static secrets. The reason for not using Secrets Manager still needs an accurate decision record.

Combining a CI build number with the source commit identifies both the run and its source. A deployment health check followed by rollback is a planned behavior; it is not implemented until tested.

## 2026-09-30 — Session 5: Source-use stance and AWS cost review

The selected interim source-use stance is to preserve attribution and the existing fork, keep a built WAR private, and avoid public distribution. This limits exposure but does not establish permission.

Stopping EC2 avoids further compute time but does not remove possible charges from associated storage or other resources. VPC endpoint type, NAT gateways, public IPv4, secrets, hosted zones, storage, and data transfer can matter; a bill line alone does not identify the resource that caused it.

AWS CLI `describe-*` and `list-*` commands inspect state without changing it. In Git Bash, `AWS_PAGER=""` avoids pager pauses; `--query` filters fields and `--output table` formats results. A summary without raw output is a reported result, not independently verified evidence.

## 2026-09-30 — Session 6: Inventory, teardown, and billing follow-up

Regional EC2/VPC commands use `--region us-east-1`; Route 53 hosted-zone listing is global and has no region flag. AWS CLI `--query` uses JMESPath; `...[].[A,B]` selects output columns.

A VPC itself has no hourly charge; resources within it may. An Application Load Balancer appears under its own service line. A VPC billing line can include endpoint or public-IPv4 usage, but the exact usage type must be checked before naming a cause.

`terraform state list` shows resource addresses recorded in the selected state. `terraform plan -destroy` refreshes AWS state and previews removals without applying them. Compare Terraform state with a live inventory because unmanaged resources may not appear in state.

Gateway endpoints and interface endpoints differ: the Project 1 S3 gateway endpoint was reported as remaining and free. A 2026-10-01 inventory confirmed one S3 gateway endpoint exists; its owning project is not verified. Project 2 interface endpoints were reported destroyed. The earlier 2026-09-30 inventory summary lacked raw output, so the Project 2 cleanup report remains historical and independently unverified by that earlier summary.

Billing can lag. Cleanup stops future use but does not remove already accrued charges; forecasts may also lag cleanup. Cost Explorer grouped by Usage type can help investigate a continuing service line. AWS Credits have eligibility and expiration rules, so a bill total alone does not show how credits applied. Recheck current official pricing before relying on any remembered rate; the prior session cited Route 53's hosted-zone pricing as an example.

## 2026-10-01 — Session 7: Read-only inventory

Empty `aws s3api get-bucket-versioning` output means versioning was never enabled, so no hidden older versions add to storage. `aws secretsmanager list-secrets --include-planned-deletion` also shows secrets scheduled for deletion; active secrets bill per secret per month. Ansible's SSM connection plugin uploads temporary module files (`AnsiballZ_ping.py`) to an S3 bucket, which is why that relay bucket holds small objects. A resource name tag does not identify which project created it.

A bill line shows gross usage and credits appear as a separate negative entry, so a zero total does not mean zero usage: the VPC line showed charges before credits were applied. Interface VPC endpoints bill per endpoint-hour even when idle; gateway endpoints are not charged. Cost Explorer's region legend lists every region with usage, so a region you do not remember using can still appear, and read-only `describe-*` commands showed whether anything remained.

## 2026-10-01 — Session 8: Phase 0 gates

`git ls-tree -r --name-only <ref>` lists tracked paths without checking out a branch; the reference-clone search found no license file on `atom` or `origin/local` and no license/copyright text in `README.md` or `pom.xml`, but a missing license is not permission. In GitHub Actions, `pull_request` runs for pull-request activity, `push` to `main` runs when commits are pushed there (typically after a merge in this planned flow), and `workflow_dispatch` is a manual run; Project 3 pull-request jobs build and test only, with no AWS access. GitHub branch protection can require a named status check after it has succeeded in the repository, and logs for public-repository runs are viewable to GitHub users with access, so never print the WAR or source contents.

## 2026-10-01 — Session 9: Repository and source-branch checks

Read-only Git/GitHub CLI checks showed the tools are installed and `gh` is authenticated with repository/workflow scopes; `pwd` caught the terminal inside the VProfile reference clone, so confirm the working directory before repository operations. Branch names and commit messages do not establish compatibility: `origin/local` and `origin/atom` are Java 17 WAR candidates, while `main` and `ci-jenkins` target Java 1.8; inspect the source/POM diff and build the chosen commit before pinning it.

## 2026-10-01 — Session 10: Local Maven package

In the VProfile scratch folder, `mvn clean package` completed with `BUILD SUCCESS` and produced `target/vprofile-v2.war` (83,278,671 bytes). A successful package output confirms an artifact was built, but the Surefire reports still need checking to record how many tests ran or were skipped.

## 2026-10-01 — Session 11: Zero-test build

Maven reports `BUILD SUCCESS` with `Tests run: 0` when Surefire's auto-detected JUnit Platform provider has only the JUnit 5 engine and the tests are JUnit 4; `junit-vintage-engine` lets JUnit 4 tests run, and VProfile's 9 tests then ran and passed. `sed -i` can convert CRLF line endings to LF, which makes `diff` report every line as changed; `diff --strip-trailing-cr` shows the real differences. `git -C <folder>` runs a Git command in another folder without changing directory.

## 2026-10-01 — Session 12: Fix location and finding a Git clone

A fork is your own GitHub copy of a repository; a submodule stores another repository's URL and one commit ID; a patch or script changes a file at build time, so the pinned source stays unmodified. A plain copy of a folder without a `.git` directory cannot run Git commands (`fatal: not a git repository`). `find <folder> -maxdepth 3 -name .git -type d` locates repositories, and `git -C <repo> remote get-url origin` shows where each was cloned from. Text left on the command line before a paste joins the first command (`sadasfind: command not found`), so clear the line first.

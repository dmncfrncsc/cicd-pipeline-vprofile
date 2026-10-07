# NOTES.md — `cicd-pipeline-vprofile` (Project 3)

These notes explain the project in the order its parts fit together. They define terms with examples from this project. `PROGRESS.md` is the place to check what is done and what comes next.

## Project map — how the parts fit

Project 3 uses instructor-provided VProfile to practice an automated build and delivery flow. In Phase 1, GitHub Actions is meant to get the pinned source, run the shared build script with Maven, and report pass or fail; this phase has no AWS access. Jenkins and AWS deployment come later, with separate design and cost approval; `PROGRESS.md` records which parts exist and what has been verified.

## 1. Choose the exact app code

**Source code** is the files that make the app. A **Git commit** is one saved version of those files. A **fork** is your own copy of someone else's Git repo. A **submodule** is a pointer from one repo to another repo at one exact commit.

**In this project:** the Project 3 repo points to VProfile source through `vprofile-src`. Pinning a commit means each build can use the same app version. Changing the pointer selects a different version.

Different VProfile branches may use different Java versions. Earlier read-only checks identified `origin/local` and `origin/atom` as Java 17 WAR candidates, and `main` and `ci-jenkins` as Java 8 candidates. A branch name does not prove the app builds; inspect its files and build it before choosing.

The VProfile app was made by the instructor, not by the author of Project 3. Earlier checks found no license file on `atom` or `origin/local`, and no license text in `README.md` or `pom.xml`. Missing license text does not grant permission. Keep attribution and do not share a built WAR publicly unless permission is established.

**Useful checks:** `pwd` shows the current folder. `git rev-parse --show-toplevel` prints the Git repository root. `git submodule status` shows the submodule commit. `git ls-tree -r --name-only <ref>` lists tracked file names at a commit without switching to it. `git -C <repo> remote get-url origin` shows that repo's remote address. A search only tells you about the folders it searched.

## 2. Build the app and make sure its tests run

**Maven and its POM:** Maven builds Java apps. POM means Project Object Model; `pom.xml` lists build settings and dependencies (libraries the app uses). The instructor supplied VProfile and its POM; developers normally maintain the POM for an app they own. In this project, the script edits the copied POM in `build-work/`, not the pinned file in `vprofile-src/`; Maven packages the app as a **WAR**.

**Why test count matters:** An earlier Maven run reported `BUILD SUCCESS` but ran 0 tests because the app's tests use JUnit 4 while Maven had only the JUnit 5 test engine. Adding JUnit Vintage made a later Maven log report 9 tests, showing why a green build alone is not enough if no tests ran.

**How JUnit Vintage fits:** JUnit Vintage lets the JUnit 5 test system run JUnit 4 tests. The shared script adds this library to the temporary POM copy, checks Maven's test summary, and leaves the pinned source POM unchanged.

**Where a dependency goes:** In XML, `<dependencies>` starts the library list and `</dependencies>` ends it. Put a new `<dependency>...</dependency>` block just before the closing tag so Maven treats it as a library.

**Build script and temporary copy:** `scripts/build.sh` copies VProfile into `build-work/`, removes the copied Git metadata, edits only the copied `pom.xml`, runs Maven, and checks the test result and WAR. Copying first keeps the pinned `vprofile-src/pom.xml` unchanged; removing `.git` from the copy is separate cleanup.

**Finding the project folder:** `BASH_SOURCE[0]` is the path Bash used to start the script. `dirname` keeps its folder, `scripts/..` goes up to the repository, and `pwd` prints that full folder path for `ROOT`; this lets the script find its files even if it is started from another folder.

**Quoted paths:** Quotes around a path or variable keep spaces together as one path. The script quotes variables such as `"$WORK"` so shell commands do not split a folder path at its spaces.

**Safe cleanup and ignored output:** `rm -rf "$WORK"` removes the folder stored in `WORK`, so the script points `WORK` to the dedicated `build-work/` folder under the repository. `.gitignore` excludes `build-work/` so its temporary source copy, Maven log, and WAR are not mistaken for files to commit.

**Conditional checks:** `A && B` runs `B` only when `A` succeeds; `A || B` runs `B` only when `A` fails. The script uses these to stop with a clear message when a required file or POM section is missing, or when the Vintage dependency is already present.

**`grep -c` and `|| true`:** `grep -c` prints how many lines contain a match; if none match, it prints 0 but returns a failure status. The script adds `|| true` so `set -e` does not stop before the later check can print a clear error.

**`if grep -Fq`:** `-F` searches for exact text, and `-q` keeps the search quiet. The script uses `if` to check whether the POM already contains the Vintage dependency; the script can then stop with its own explanation if it finds it.

**Exit code and syntax check:** `$?` holds the result of the previous command; 0 means success. `bash -n scripts/build.sh` checks Bash syntax without running the script, so it cannot prove the Maven build works.

**POM edit with sed:** `s#OLD#NEW#` means “replace OLD with NEW”; `#` marks the boundaries, and it is used because the old text contains `/`. The command replaces every match, so the script checks that the POM has exactly one opening and one closing dependencies tag first.

The replacement must put `</dependencies>` back. Without it, the POM is invalid XML, even if `sed` itself succeeds; Maven reports the problem when it reads the file. Without `-i`, `sed` only prints the edited text and changes no file; with `-i`, it saves the edit into the file.

**Maven command:** In `mvn -B clean package`, `-B` selects batch mode, `clean` removes old build output, and `package` builds the app, runs configured tests, and creates the WAR. The script checks the Maven log for a positive test count because an earlier build succeeded while running zero tests.

**Output channels and redirection:** Bash labels its two output routes `1` and `2`. Route `1` is normally for regular output, and route `2` is normally for error output; both usually appear in the terminal. Redirection decides where they go.

`> out.txt` redirects route `1` to a file, so route `2` stays on screen. `2>&1` sends route `2` to the same place as route `1`; for example, `demo > out.txt 2>&1` sends both to the file.

**Failure settings:** In `set -euo pipefail`, `-e` stops the script after an unhandled command failure, `-u` treats an unset variable as an error, and `pipefail` makes a pipeline fail if any command in it fails. This lets a Maven failure in `mvn ... | tee mvn.log` reach `-e` even if `tee` succeeds.

**Pipe and tee:** `|` sends channel 1 from the command on its left to the command on its right; `tee mvn.log` writes received output to both the screen and `mvn.log`. In `mvn ... 2>&1 | tee mvn.log`, `2>&1` combines channel 2 with channel 1 before the pipe, so both can reach `tee`.

**Positive test-count pattern:** A regular expression (regex) is a text pattern used to find a match. In `[1-9][0-9]*`, the first digit must be 1–9, and `*` allows zero or more digits after it; `9` and `12` match, but `0` does not. The script uses this to reject `Tests run: 0`, but it checks for a positive test-result line rather than adding up every suite.

**Line endings:** LF (`\n`) is one character; CRLF (`\r\n`) is a carriage return followed by a line feed. The pinned POM has 321 CRs and 321 LFs, so each line ends with CRLF. `git ls-files --eol` shows how Git stores a file (`i/`) and how the checked-out file is stored (`w/`). `i/lf w/crlf` means Git stores LF and the checked-out file uses CRLF.

**What the line-ending check showed:** `sed -i` changed the whole scratch copy and the whole `build-work/pom.xml` copy to LF. Direct byte counts found 0 CR and 321 LF in each copy; the pinned source still has 321 CR and 321 LF. The Maven log from the `build-work/` run shows that copy built successfully with 9 tests. This verifies that run on this machine; it does not verify other `sed` versions or platforms.

**Seeing line endings:** `cat -A` can show `$` at an LF line end and `^M$` at a CRLF line end; `od -c` displays the actual `\r` and `\n` characters. In the Git Bash check for this POM, `grep -c $'\r'` returned 0 even though `od` found 321 CR characters, so that grep result was not reliable for this file.

**Comparing files with different line endings:** If one file uses CRLF and another uses LF, `diff` may show every line as changed. GNU `diff --strip-trailing-cr old-file new-file` ignores the trailing CR so the output focuses on text changes.

## 3. Run the build checks automatically

**Continuous integration (CI)** means a computer automatically builds and checks code when a change happens. A pipeline is the list of steps that computer runs. A GitHub Actions **workflow** is the file that tells GitHub which steps to run and when. The pipeline can live beside the app code or in a separate repo that fetches a pinned app version; the repo layout is still undecided.

GitHub Actions is planned for the first phase. A `pull_request` starts checks for a proposed change, a `push` to `main` starts checks after code is pushed there, and `workflow_dispatch` starts a run by hand. **Polling** checks for changes on a timer; a **webhook** sends a message when a change happens, such as after a push. Example: for a pull request, the planned workflow builds and tests the code, then shows a pass or fail result. It does not use AWS. A **required status check** is a passing job GitHub must see before it allows a change into `main`; it can be required after it has succeeded once.

Public-repo logs may be visible to other people. Never print VProfile source files, WAR contents, passwords, or keys in those logs. Hosted CI computers save you from running your own Jenkins server, but they may not be able to reach a private EC2 computer.

Jenkins is planned for the next phase. Its **controller** organizes jobs; an **agent** computer runs their commands. The instructor's `Jenkinsfile` is not the design source for this project; design the pipeline from the project needs. The course also covers GitLab CI/CD, but the exact lecture order and instructor repo layout were not verified.

## 4. Save and deliver the built app

The WAR is the file made by the build. **Nexus** stores versioned build files; it does not build or run the app. **S3** can also store files. For example, a private artifact store could keep the VProfile WAR made by a successful build. **SonarQube** checks code quality. Whether to use Nexus or SonarQube is still undecided.

A build number plus the source commit can identify which run made a WAR and which app version it used. A health check can see whether the deployed app responds. A rollback can return to an earlier version if the new one fails. These are planned behaviors, not completed or tested features.

The WAR must stay private. Do not put it in a public repo, release, or log. The source-use permission is unresolved, so attribution must stay and public sharing of the built WAR is not allowed unless permission is established.

## 5. Add AWS resources only after the design and cost gate

**Terraform** is planned to create cloud resources such as networks, computers, and permissions. **Ansible** is planned to install software and set up computers and apps. Terraform **state** is its saved list of resources. S3 versioning and encryption are planned for remote state; the locking choice must match the Terraform version.

An AWS **IAM role** gives a computer limited AWS permissions. For example, a build computer should get only the AWS access it needs. Jenkins credentials can hold tool tokens. Do not commit passwords or keys. The reason for not using Secrets Manager still needs to be recorded.

AWS Systems Manager (SSM) port forwarding can provide private access to a Jenkins screen without opening public SSH. A webhook or load balancer needs a separate network and cost review. A hosted CI computer cannot automatically connect to a private EC2 computer.

Project 3 owns its own AWS resources and Terraform state. It does not automatically reuse buckets, secrets, networks, or other resources from Projects 1 and 2. A reuse plan needs clear ownership, written approval, and a live check. The resource name or tag alone does not prove which project owns it.

## 6. Check AWS costs and live resources carefully

Stopping an EC2 computer stops its compute use, but storage and other resources can still cost money. A VPC is an AWS private network; the VPC itself has no hourly charge, while some resources in it can. An Application Load Balancer has its own billing line. Interface VPC endpoints can charge by the hour even when idle; S3 gateway endpoints have no endpoint-hour charge. Check current prices before making a cost decision.

Bills can update late. Cleaning up stops later use but does not remove earlier charges. A bill can show a charge and a separate credit that subtracts from it, so a zero total does not mean there was no usage. Cost Explorer can group charges by usage type. A service line alone may not prove which resource caused it.

Earlier checks found that an empty `aws s3api get-bucket-versioning` response meant versioning was not enabled for that bucket. `aws secretsmanager list-secrets --include-planned-deletion` also shows secrets waiting to be deleted; active secrets are billed monthly. Ansible's SSM connection can put temporary files such as `AnsiballZ_ping.py` in S3 while it works. These facts do not identify which project owns a bucket or secret.

An S3 gateway endpoint for Project 1 was reported as still present and free; a later check found one, but did not prove its owner. Project 2 interface endpoints were reported as removed, but an earlier summary had no raw command output, so that report was not independently checked.

AWS CLI `describe-*` and `list-*` commands inspect settings without changing them. Most regional EC2 and VPC checks used `--region us-east-1`. Route 53 hosted-zone listing is global and has no region option. AWS CLI `--query` uses JMESPath, a small language for picking fields from command results; `...[].[A,B]` selects two columns. Cost Explorer can group charges by usage type and show regions with usage. `AWS_PAGER=""` prevents output from pausing, and `--output table` makes a table.

## 7. Read command results before trusting them

`terraform state list` shows resources recorded in the selected Terraform state. `terraform plan -destroy` refreshes the state and previews what Terraform would remove; it does not remove anything. Compare that list with live AWS resources because something created outside Terraform may be missing from the state.

Git Bash maps the Windows `G:` drive to `/g`; quote a path that contains spaces, for example `"/g/Tutorial Folder/..."`. `pwd` shows the current folder, and `git rev-parse --show-toplevel` prints the Git repository root; use it to confirm you are in `cicd-pipeline-vprofile`, not the nested `vprofile-src/` repo. A plain folder copy without `.git` is not a Git repo, so Git commands fail there. Clear the command line before pasting; leftover text can join the next command and break it.

A syntax check, a Maven log, a created WAR, and the script's final success message prove different things. For example, `bash -n` checks only syntax, while the Maven log and WAR show that a build ran; keep the evidence and current handoff status in `PROGRESS.md`.

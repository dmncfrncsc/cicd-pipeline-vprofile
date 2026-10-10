# NOTES.md — `cicd-pipeline-vprofile` (Project 3)

These notes explain the project in the order its parts fit together. They define terms with examples from this project. `PROGRESS.md` is the place to check what is done and what comes next.

## Project map — how the parts fit

Project 3 uses instructor-provided VProfile to practice an automated build and delivery flow. In Phase 1, GitHub Actions gets the pinned source, runs the shared build script with Maven, and reports pass or fail; this phase has no AWS access. Jenkins and AWS deployment come later, with separate design and cost approval; `PROGRESS.md` records which parts exist and what has been verified.

## 1. Choose the exact app code

**Source code** is the files that make the app. A **Git commit** is one saved version of those files. A **fork** is your own copy of someone else's Git repo. A **submodule** is a pointer from one repo to another repo at one exact commit.

**In this project:** the Project 3 repo points to VProfile source through `vprofile-src`. Pinning a commit means each build can use the same app version. Changing the pointer selects a different version.

A submodule stores an exact commit ID, not a branch name. `git ls-remote` lists references advertised by the remote, so not seeing a commit ID there does not prove that the commit cannot be fetched; a commit that no retained reference points to may later become unavailable.

Different VProfile branches may use different Java versions. Earlier read-only checks identified `origin/local` and `origin/atom` as Java 17 WAR candidates, and `main` and `ci-jenkins` as Java 8 candidates. A branch name does not prove the app builds; inspect its files and build it before choosing.

The VProfile app was made by the instructor, not by the author of Project 3. Earlier checks found no license file on `atom` or `origin/local`, and no license text in `README.md` or `pom.xml`. Missing license text does not grant permission. Keep attribution and do not share a built WAR publicly unless permission is established.

**Useful checks:** `pwd` shows the current folder. `git rev-parse --show-toplevel` prints the Git repository root. `git submodule status` shows the submodule commit. `git ls-tree -r --name-only <ref>` lists tracked file names at a commit without switching to it. `git -C <repo> remote get-url origin` shows that repo's remote address. A search only tells you about the folders it searched.

## 2. Build the app and make sure its tests run

**Maven and its POM:** Maven builds Java apps. POM means Project Object Model; `pom.xml` lists build settings and dependencies (libraries the app uses). The instructor supplied VProfile and its POM; developers normally maintain the POM for an app they own. In this project, the script edits the copied POM in `build-work/`, not the pinned file in `vprofile-src/`; Maven packages the app as a **WAR**.

**Why test count matters:** An earlier Maven run reported `BUILD SUCCESS` but ran 0 tests because the app's tests use JUnit 4 while Maven had only the JUnit 5 test engine (earlier explanation; see the caution below). Adding JUnit Vintage made a later Maven log report 9 tests, showing why a green build alone is not enough if no tests ran.

**Caution (run details verified; explanation unverified, 2026-10-07):** In PR #2, the run without the script's Vintage insertion reported 9 tests with Surefire 3.6.0; a later run with Surefire 3.5.4 reported 0. The runner images also differed. The linked [runner-image release notes](https://github.com/actions/runner-images/releases/tag/ubuntu24/20261004.327) are reported to list Maven 3.9.16 on image `20260927.320.1` and 3.10.0 on image `20261004.327.1`; that page has not been independently reviewed. The linked [Surefire 3.6.0 guide](https://maven.apache.org/surefire-archives/surefire-LATEST/maven-surefire-plugin/whats-new-3-6-0.html) is reported to say that Surefire 3.6.0 can automatically provide Vintage support for JUnit 4; that guide has not been independently reviewed. This could explain the run comparison, but it is not proven: the logs do not print Maven's version or identify the exact engine loaded. The 3.5.4 run reported 0 tests, but that does not prove older Surefire versions always miss these tests. The script's test-count pattern was also changed to `99999` before the later run, so that run does not prove the original zero-test guard works; Maven's zero-test result is separate evidence. Keep the Vintage insertion to make the build work across the observed plugin versions.

**Reading plugin versions in a Maven log:** A plugin line can look like `--- surefire:3.6.0:test (default-test) @ vprofile ---`; the number after the plugin name is the version used in that run. When comparing runs, check these plugin lines, the `Using auto detected provider` line, the `Tests run:` total, the runner image, and the submodule commit. PR #2's image and plugin versions differed; Run #8's script also had its test-count pattern changed to `99999`, which forced the later script error after Maven and did not cause Maven's zero-test result.

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

**Continuous integration (CI)** means a computer automatically builds and checks code when a change happens. A pipeline is the list of steps that computer runs. A GitHub Actions **workflow** is the file that tells GitHub which steps to run and when. In this project, the pipeline lives in its own repository and gets the pinned VProfile version through the `vprofile-src` submodule.

The Phase 1 workflow is configured for three events: `pull_request` checks a proposed change, `push` to `main` checks a commit after it is pushed, and `workflow_dispatch` starts a run by hand. The job builds and tests without AWS access. **Polling** checks for changes on a timer; a **webhook** sends a message when a change happens, such as after a push. A **required status check** is a passing job GitHub must see before it allows a change into `main`; the ruleset `protect-main` now requires `build-test` (verified 2026-10-07).

Public-repo logs may be visible to other people. Not uploading an artifact does not hide text printed by `tee`; build output still appears in the workflow log. Never print VProfile source files, WAR contents, passwords, or keys in those logs. A GitHub-hosted runner cannot directly connect to an EC2 instance in a private subnet; deployment needs an AWS-managed path such as SSM.

Jenkins is planned for the next phase. Its **controller** organizes jobs; an **agent** computer runs their commands. The instructor's `Jenkinsfile` is not the design source for this project; design the pipeline from the project needs. The course also covers GitLab CI/CD, but the exact lecture order and instructor repo layout were not verified.

Project 3's infrastructure and playbooks are being designed from project requirements. Course provisioning scripts are not required and will not be inspected or copied; choose the target OS from verified AWS, SSM, and package needs rather than script similarity.

**Runner and steps:** A runner is the temporary computer GitHub provides for a job; the hosted runner is removed when the job ends. In this workflow, checkout gets the repository and pinned submodule, setup-java installs Temurin 17, and `run: bash scripts/build.sh` starts the build, so each run repeats the setup.

A **runner image** is the set of software installed on the hosted runner, such as Java and Maven. Its version appears under **Runner Image** in the Set up job log. GitHub updates images over time, so the same workflow can use different software versions on different runs; the separate **Hosted Compute Agent** block describes GitHub's runner service, not the image (verified from PR #2 logs).

**Actions, commands, and names:** A step with `uses:` runs a packaged action; this workflow uses checkout and setup-java actions from other repositories, while `run:` executes a shell command. Step names label log sections, but the workflow name feeds `github.workflow` in the concurrency group and the job name identifies the status check, so changing those names can affect cancellation grouping or required-check matching.

**SHA pinning:** A full commit SHA selects one exact version of action code, while a version tag is a name that its owners can move. This workflow pins checkout and setup-java by SHA, so a newer action version is used only after the workflow's SHA is changed.

**Token and permissions:** GitHub gives each workflow run a `GITHUB_TOKEN`, and `permissions` limits what that token can do. `contents: read` allows the workflow to read repository contents without permission to push changes; `persist-credentials: false` tells checkout not to save the token as a Git credential in the repository's local configuration.

**Concurrency groups:** This workflow builds a group from `github.workflow` and `github.ref`. With `cancel-in-progress: true`, a new run cancels an older run only when they share a group and the older run is still running; two runs on `main` share a group, while a pull request uses a different ref.

**Three triggers (verified 2026-10-07):** `push` runs after a commit lands on `main`, `workflow_dispatch` runs when you click "Run workflow" by hand, and `pull_request` runs on a proposed change before it merges. In this project, run #4 was manual (40 s), and PR #1's check passed (28 s).

**Pull request (PR):** A PR asks GitHub to merge one branch into another, such as `docs/record-phase1-checks` into `main`. GitHub tests a temporary merge of the two; the PR #2 log shows `refs/remotes/pull/2/merge`. A PR is how a change reaches `main` now.

**Ruleset and required check (verified 2026-10-07):** A ruleset is a set of rules GitHub applies to chosen branches. `protect-main` is active on `main`, requires `build-test` from GitHub Actions, and blocks force pushes. On PR #2, the failing check carried a Required badge and the Merge button was disabled. A direct push to `main` should now be refused, but that was not tested.

**Why test a failure path:** A pipeline that has only passed has not shown it can fail. In PR #2, the count pattern was changed to `99999`, so the job ended with `ERROR: Maven did not report any tests as run.` and exit code 1, even though Maven said `BUILD SUCCESS`. This shows the script's error path works. It does not show the original check rejects 0 tests, because `99999` fails for any count.

**Token permissions (verified):** The Set up job log listed only `Contents: read` and `Metadata: read`, so the workflow cannot push changes to the repository.

**Checkout credential cleanup (verified):** With `persist-credentials: false`, checkout stores a temporary credential file outside the repository and adds `includeIf` pointers to it in the repo's config. After the checkout, it removes the pointers and logs `Removing credentials config`. The hosted runner is deleted when the job ends.

**Apps that add checks (verified access, reported origin):** A GitHub App with "All repositories" access can add its own check and comment to a PR without appearing in the workflow file. SonarQubeCloud did this on PRs #1 and #2. You reported it came from your Udemy course. It is not part of Project 3's scope.

## 4. Save and deliver the built app

The WAR is the file made by the build. **Nexus** stores versioned build files; it does not build or run the app. **S3** can also store files. For example, a private artifact store could keep the VProfile WAR made by a successful build. **SonarQube** checks code quality. Whether to use Nexus or SonarQube is still undecided.

A build number plus the source commit can identify which run made a WAR and which app version it used. A health check can see whether the deployed app responds. A rollback can return to an earlier version if the new one fails. These are planned behaviors, not completed or tested features.

The WAR must stay private. Do not put it in a public repo, release, or log. The source-use permission is unresolved, so attribution must stay and public sharing of the built WAR is not allowed unless permission is established.

**Private S3 and retention (planned):** Block Public Access blocks public access, while encryption protects stored data but does not decide which role may read or write. The WAR bucket would let the GitHub role upload and the instance role download. Versioning keeps an older copy when an object key is overwritten; a lifecycle rule removes objects by age or other rules. Unique keys and retention can keep earlier WARs for rollback; bucket names and retention are undecided.

**Health check (planned):** A health check asks whether the deployed VProfile app is ready to serve requests. The port, real app URL, and response that proves the app is healthy are undecided; Tomcat port `8080` is only a candidate from memory. A generic HTTP `200` may not prove the VProfile page or its dependencies are working. The check should retry while Tomcat starts, and its result must determine whether deployment succeeded. The user's SSM port-forwarding session is for manual viewing; the proposed automated check would run on the instance through SSM Run Command because a GitHub-hosted runner cannot directly reach the private instance.

## 5. Add AWS resources only after the design and cost gate

**Terraform** is planned to create cloud resources such as networks, computers, and permissions. **Ansible** is planned to install software and set up computers and apps. Terraform **state** is its saved list of resources. S3 versioning and encryption are planned for remote state; the locking choice must match the Terraform version.

An AWS **IAM role** gives a computer limited AWS permissions. For example, a build computer should get only the AWS access it needs. Jenkins credentials can hold tool tokens. Do not commit passwords or keys. The reason for not using Secrets Manager still needs to be recorded.

**SSM access:** Systems Manager Session Manager lets a person open a shell or forward a port to an EC2 instance. The SSM Agent starts outbound connections to AWS, so Session Manager does not need inbound SSH and does not give the instance general internet access.

**Port forwarding (planned):** A port is a number that directs a connection to a program, such as Tomcat. SSM port forwarding connects a local port to the instance through the SSM Agent's outbound session, so it needs no inbound connection. When the user opens `http://localhost:8080`, the request is forwarded to the chosen Tomcat port on the instance. The tunnel works only while the local forwarding command is running. `8080` is an example only; the target port still needs confirmation.

**Private network and updates:** A public subnet has a route to an internet gateway; a private subnet does not route directly to that gateway. A NAT Gateway in the public subnet lets a private instance start outbound connections to SSM and package or plugin sites. If NAT is the only outbound path, deleting it while keeping the instance stops SSM and package access; the instance then needs another SSM path and a separate package source, or the whole stack must be destroyed.

**Public-IP fallback (planned):** A public IPv4 address and route to an internet gateway let an instance start outbound connections. A security group with no inbound rules still blocks new connections from starting at the instance, but the public address makes accidental inbound-rule changes a larger risk and departs from the private-subnet design.

**Package setup:** SSM interface endpoints provide a private path to SSM, but not to arbitrary package sites. An S3 gateway endpoint routes a VPC's traffic to S3 without NAT and has no hourly endpoint charge; it does not reach package sites. A prepared Amazon Machine Image (AMI) can include software before an instance starts, but it must be rebuilt to receive later package and security updates.

**OIDC and access keys:** An AWS access key has an ID and a secret key. A program can use that pair until it is disabled or deleted. With OIDC, each GitHub Actions run presents AWS with a short-lived identity token; AWS checks a rule about the repository and branch, then returns temporary credentials if the token matches. This avoids storing a long-lived AWS access key in GitHub. The linked [AWS guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp-oidc.html) describes repository and branch restrictions; whether AWS can also limit this role to one specific workflow remains unverified.

**Temporary credentials and logs (planned):** Temporary AWS credentials stop working at expiry, which limits how long a leaked value can be used. They are still sensitive while valid, so never print them in a public workflow log.

**Trust and permissions policies (planned):** An IAM role has a trust policy that says who may use it and a permissions policy that says what it may do. The proposed GitHub role would trust only this repository's `main` branch and upload the WAR or start the limited deployment command; the instance role would read the WAR and support SSM. These separate roles have not been created.

**Three permission paths (planned):** The CI role needs upload and deploy access, the EC2 role needs WAR-download and SSM-agent access, and the controller running Ansible needs SSM-session and possibly transfer-bucket access. These are three permission sets, but they do not necessarily require three separate AWS identities.

**Instance profile (planned):** An instance profile attaches an IAM role to an EC2 instance. The instance can then receive temporary AWS credentials for actions such as downloading the WAR, instead of storing a long-lived key on disk.

**SSM command document (planned):** An SSM document defines a command that Systems Manager can run on an instance. A fixed deployment document could limit the GitHub role to approved deploy steps; permission to run a general shell document could allow broader commands. This choice is not designed or implemented.

**Secrets in a public repository:** GitHub secrets are not shown just because a repository is public. Workflow code or an action that can read a secret could still expose it, so a long-lived AWS access key should not be treated as safe just because it is stored as a secret.

**Planned GitHub-to-instance path:** The proposed `main` workflow would upload the WAR to private S3, then use Systems Manager Run Command (AWS's way to send a command to an instance managed by SSM). The private instance would download the WAR using its own limited IAM role; the hosted runner would not open an inbound connection to it. Pull-request runs must have no AWS access. The exact AWS rules, permissions, and network route remain unapproved and unimplemented.

**Terraform state, backend, and locking (planned):** State is Terraform's record of the resources it manages. A backend stores that record, and a lock prevents overlapping changes from using the same state at once. Remote S3 state with `use_lockfile = true` is proposed. Research text supplied in the conversation reports that this setting requires Terraform 1.10 or later; a sufficiently recent CLI does not prove that locking works with the chosen backend. The backend has not been initialized and locking has not been tested.

Installing Terraform on the controller is separate from initializing Terraform for a project. Installation makes the CLI available in that shell environment; `terraform init` configures the project's providers and backend. Installing the CLI alone does not contact AWS, create project resources, or create Terraform state.

**Terraform and Ansible (planned):** Terraform creates the network, permissions, and EC2 instance. Ansible configures software on a computer that already exists; it does not replace Terraform's infrastructure work.

**Ansible playbook and idempotence (planned):** A playbook lists the computer setup tasks, such as installing MySQL and starting its service. Idempotence means rerunning the playbook leaves an already-correct computer unchanged, which supports rebuilding this lab reliably.

**Ansible over SSM (planned; transfer details unverified):** The `aws_ssm` connection would send Ansible's commands through Systems Manager instead of inbound SSH. Research text supplied in the conversation reports that the connection uses S3 for temporary helper files, the controller needs upload/download/list/delete access, and the instance receives a presigned link; it also says not to enable versioning on the transfer bucket. These are reported requirements, not independently checked for the installed collection. Confirm the exact behavior and permissions before the design gate, and keep any transfer bucket private.

**Local AWS identity (reported setup; identity unknown):** A `[default]` profile is only a profile name; it can refer to long-lived or temporary credentials. `aws sts get-caller-identity` contacts AWS and tells which identity is calling, but it does not show what that identity is allowed to do.

**IAM Identity Center and role sessions (possible controller options):** Signing in through IAM Identity Center can provide short-lived CLI credentials; assuming a limited IAM role can also provide temporary, scoped credentials to an existing identity. Neither is confirmed for this AWS profile; a `[default]` heading does not reveal which credential source is active.

**AMI and operating system (planned):** An AMI is the disk image an EC2 instance starts from and includes one operating system. The Ubuntu computer running Ansible can manage a different target OS; the playbook must use the target OS's package and service details.

**VProfile service names (reported from pasted configuration):** The app expects `db01` for MySQL, `mc01` for Memcached, and `rmq01` for RabbitMQ. Research text supplied in the conversation reports that the app uses MySQL Connector/J 8.0.33, `com.mysql.cj.jdbc.Driver`, and `jdbc:mysql://db01:3306/accounts`; MariaDB compatibility is untested. Its standby Memcached address is `127.0.0.2`, a loopback address that refers to the same host from the app's point of view. How the app uses that standby address still needs a read-only check. Binding a service to loopback and blocking inbound network traffic with a security group are separate controls. The configuration contains fixed service credentials, and their values do not belong in these notes.

**Service-name resolution (planned):** The strings in app properties are hostnames, so each name must resolve to an IP address through DNS or `/etc/hosts`. On one instance, all three service names can point to the same address; across multiple instances, they must point to the individual service hosts. Changing layout therefore changes name mappings and inventory as well as the service machines.

A Jenkins webhook or load balancer is outside the current plan; either needs its own network and cost review before use.

Project 3 owns its own AWS resources and Terraform state. It does not automatically reuse buckets, secrets, networks, or other resources from Projects 1 and 2. A reuse plan needs clear ownership, written approval, and a live check. The resource name or tag alone does not prove which project owns it.

## 6. Check AWS costs and live resources carefully

Stopping an EC2 computer stops its compute use, but storage and other resources can still cost money. A VPC is an AWS private network; the VPC itself has no hourly charge, while some resources in it can. An Application Load Balancer has its own billing line. Interface VPC endpoints can charge by the hour even when idle; S3 gateway endpoints have no endpoint-hour charge. Check current prices before making a cost decision.

Bills can update late. Cleaning up stops later use but does not remove earlier charges. A bill can show a charge and a separate credit that subtracts from it, so a zero total does not mean there was no usage. Cost Explorer can group charges by usage type. A service line alone may not prove which resource caused it.

**Hourly costs and teardown (planned):** Stopping an instance stops its compute charge, but its EBS disk can keep billing until deleted; NAT Gateways, public IPv4 addresses, and SSM interface endpoints can also keep hourly charges while they exist. Way 1 proposes destroying the stack after each session and rebuilding it, which gives a fresh database next time. The separate state and WAR buckets may remain and incur storage charges, so check Terraform state and live AWS resources after destroy.

Earlier checks found that an empty `aws s3api get-bucket-versioning` response meant versioning was not enabled for that bucket. `aws secretsmanager list-secrets --include-planned-deletion` also shows secrets waiting to be deleted; active secrets are billed monthly. Ansible's SSM connection can put temporary files such as `AnsiballZ_ping.py` in S3 while it works. These facts do not identify which project owns a bucket or secret.

An S3 gateway endpoint for Project 1 was reported as still present and free; a later check found one, but did not prove its owner. Project 2 interface endpoints were reported as removed, but an earlier summary had no raw command output, so that report was not independently checked.

AWS CLI `describe-*` and `list-*` commands inspect settings without changing them. Most regional EC2 and VPC checks used `--region us-east-1`. Route 53 hosted-zone listing is global and has no region option. AWS CLI `--query` uses JMESPath, a small language for picking fields from command results; `...[].[A,B]` selects two columns. Cost Explorer can group charges by usage type and show regions with usage. `AWS_PAGER=""` prevents output from pausing, and `--output table` makes a table.

## 7. Read command results before trusting them

`terraform state list` shows resources recorded in the selected Terraform state. `terraform plan -destroy` refreshes the state and previews what Terraform would remove; it does not remove anything. Compare that list with live AWS resources because something created outside Terraform may be missing from the state.

Git Bash maps the Windows `G:` drive to `/g`; quote a path that contains spaces, for example `"/g/Tutorial Folder/..."`. `pwd` shows the current folder, and `git rev-parse --show-toplevel` prints the Git repository root; use it to confirm you are in `cicd-pipeline-vprofile`, not the nested `vprofile-src/` repo. A plain folder copy without `.git` is not a Git repo, so Git commands fail there. Clear the command line before pasting; leftover text can join the next command and break it.

A syntax check, a Maven log, a created WAR, and the script's final success message prove different things. For example, `bash -n` checks only syntax, while the Maven log and WAR show that a build ran; keep the evidence and current handoff status in `PROGRESS.md`.

**`git pull --ff-only origin main`:** `origin` is the remote's short name, and `main` is the branch to update. `--ff-only` moves local `main` forward when it is simply behind the remote; if the histories have diverged, Git stops instead of making a merge commit. This is useful after creating a file through GitHub's web UI.

**The Git pager:** Git may show long output one screen at a time; press `q` to leave the pager. `git --no-pager <command>`, such as `git --no-pager diff --stat NOTES.md`, prints the command's output without opening it.

**A submodule pin, a branch, and a tag:** The Project 3 submodule points to one exact VProfile commit, `9f22748`. A detached HEAD means Git has checked out that commit without putting the folder on a branch; a branch can move to later commits, while a tag is a name meant to stay on one commit. A remote branch or tag can keep the commit reachable for future clones while that reference exists, so check source-use permission before publishing a tag.

**Surefire and test engines:** Surefire is the Maven plugin that runs tests. JUnit 4 and JUnit 5 are different test systems, and the Vintage engine lets JUnit 5 run JUnit 4 tests. The linked [Surefire 3.6.0 guide](https://maven.apache.org/surefire-archives/surefire-LATEST/maven-surefire-plugin/whats-new-3-6-0.html) is reported to say the plugin automatically adds Vintage for JUnit 4; that guide was not independently reviewed in this session. The PR #2 run comparison is consistent with this report, but does not prove which engine loaded in either run. `mvn dependency:tree -Dincludes=org.junit.vintage` showed no Vintage engine in the project's dependencies, but that does not show what Surefire adds on its own.

**Commands used:** `git show <commit> -- <file>` shows what one commit changed in one file. `git fetch --prune` removes local pointers to branches deleted on GitHub (it printed `[deleted] ... origin/test/failure-path`). `git branch -d` deletes a branch only if it is merged, and `-D` forces it. `git switch -c <name>` creates and enters a new branch. `git status -sb` prints a one-line branch summary. `cut -c1-100` trims long lines so output stays readable.

**Login shell and `PATH` (verified):** A command can be installed but not found if its folder is missing from the current shell's `PATH`. Ansible was found in WSL Ubuntu's login shell; a `command not found` result from a non-login shell did not prove it was uninstalled.

**Current folder and relative paths (verified):** A relative path such as `vprofile-src/...` starts from the current folder. It can fail from the Ubuntu home folder even when the file exists in the repository, so check the working folder before using a relative path.

**Reading AWS settings safely (verified):** The AWS setup check showed section and setting names only, not credential values. Read only the names needed to understand the profile; displaying credential files can expose secrets.

**WSL distributions and shell installs (verified):** WSL distributions are separate Linux environments. Use Ubuntu WSL for the project tools; `docker-desktop` is a different distribution. Git Bash is a separate Windows shell with its own tool installations and AWS settings. Installing Terraform in Ubuntu WSL does not update or replace the Git Bash copy.


**Installing software with apt and a signing key (verified 2026-10-10):** `apt` is Ubuntu's tool for installing software from lists of packages. HashiCorp signs its list with a key, and a fingerprint is a short ID computed from that key; if the saved key's fingerprint equals the one HashiCorp publishes, the key is the real one. In this project the saved key's fingerprint matched the published value (the published value came from pasted research, reported), then `apt update` and `apt install terraform` put Terraform v1.16.5 in Ubuntu WSL.

**`sudo` and a real terminal (verified 2026-10-10):** `sudo` runs one command with administrator rights, which is needed to write in system folders such as `/usr/share/keyrings/`. A command started from Git Bash as `wsl -d Ubuntu -- bash -c '...'` did not show a password prompt, and the key file was not created. The same command typed in a real Ubuntu window asked for the password and created the file.

**Loopback address and security group (planned; not configured):** A service that listens only on `127.0.0.1` accepts connections only from the same computer. A security group with no inbound rules separately blocks network connections to the instance. They are two different controls, and the one-instance design would need both. On Linux, `127.0.0.2` is normally also a loopback address (general knowledge, not checked for this app), so how VProfile uses its standby Memcached address at `127.0.0.2` still needs a read-only check.

**Memcached active and standby hosts (reading of the code, not a tested run; 2026-10-10):** Memcached is a program that keeps recent data in memory so the app can read it quickly. VProfile is configured with an active host, `mc01`, and a standby, `127.0.0.2`. The app first connects to `mc01` and asks for the server's process ID; if that works, it uses `mc01`, and only if it fails does it try `127.0.0.2`. On one instance, `mc01` would point to the instance itself, so Memcached running there means the standby is not used. What the app does if both fail was not seen.

# Decision: Resolve Jenkins plugin dependencies to the latest compatible versions

**Status:** The plugin-resolution change was implemented in PR #135, merged at `50b3172`, and its seventh-test boot/build are reported. The separate Jenkins core pin changed to 2.580.2 in PR #137, merged at `c2288a0`; the eighth-test boot and Build #2 are reported. This decision covers plugin dependency resolution only. The eighth-test UI version, warning state, and resolved-plugin inventory were not captured.

## Context

The Jenkins controller boot log reported 20 plugin-advisory entries across seven resolved plugin names. `jenkins/plugins.txt` contains six requested plugins; only `configuration-as-code` has an explicit version. The other requested entries and their dependency graph are not fully pinned. The earlier plugin installation command included `--latest=false`; the authorized plugin research reported that this selected minimum dependency versions.

The warning block referred to resolved dependencies, not just the six direct entries. In particular, `script-security` was a resolved dependency, not a direct entry in `plugins.txt`. A full resolved-plugin inventory for that earlier boot was not yet available when the warning was first seen.

## Decision

Remove only `--latest=false` from the plugin-install command and allow the manager to resolve the latest versions compatible with the requested plugins. Do not add broad AWS permissions or change the Jenkins core version as part of this plugin-resolution change.

The author approved the one-line boot-script change. PR #135 reports the change merged at `50b3172`. The seventh-test controller log and UI were reported to show the boot checks passing and no plugin-advisory warnings on Manage Jenkins. The pasted plugin-manager JSON contains 63 resolved plugins. Seven names previously associated with the 20 plugin-advisory entries resolved at or above the fixes identified in the authorized official-source research. This is one-boot, author-reported evidence; it does not prove that the whole plugin set is vulnerability-free or that future boots will resolve identically.

## Alternatives and trade-offs

- **Keep `--latest=false`:** retains the earlier minimum-dependency resolution behavior and the observed warning state; not selected.
- **Pin the complete resolved graph:** improves repeatability but requires maintaining versions for transitive dependencies as well as requested plugins; not selected.
- **Pin only the six requested entries:** does not pin the dependency graph and would not by itself establish the resolved versions; not selected as a complete solution.
- **Upgrade Jenkins core:** separate from plugin resolution. It was implemented separately in PR #137 and tested in the eighth test; see the status and evidence below.

The chosen behavior reduces staleness in dependency resolution but accepts version drift across boots. The sixth-test response had 60 plugin names; the seventh-test response had 63, with three additional names (`jackson-annotations2-api`, `jakarta-xml-bind-api`, and `woodstox-core-api`) and 47 changed versions among the 60 shared names. These are differences between two snapshots, not proof that the flag alone caused every version change; available metadata and time also differ. The full snapshots are in [NOTES.md](../../NOTES.md#sixth-test-resolved-jenkins-plugin-inventory) and [NOTES.md](../../NOTES.md#seventh-test-resolved-jenkins-plugin-inventory).

## Separate Jenkins core advisory

The supplied, authorized official-source research identified the [2026-10-28 Jenkins core advisory](https://www.jenkins.io/security/advisory/2026-10-28/) and lists LTS 2.580.2 and weekly 2.588 as fixed versions. The [2.580.2 changelog](https://www.jenkins.io/changelog-stable/#v2.580.2) lists JDK 21 and 25 as tested configurations. The author reports the Debian package index listed 2.580.2 before the eighth test; the controller log later reported the package unpacked and set up. The pin change was committed as `0f2a248` and merged in PR #137 at `c2288a0`. The eighth-test Build #2 reportedly passed, but the author did not open Manage Jenkins; the UI version and warning state were not captured, so this test does not show the advisory closed by UI evidence. The setup-based exploitability comments were inferences, not exploitability tests, and do not clear the core version.

## Evidence limits

The fifth- through eighth-test output, boot logs, plan summaries, and teardown checks are reported in the supplied conversation and were not independently checked for this record. The seventh-test result reports Ansible `ok=25 changed=16 failed=0`; the eighth-test Build #2 reports nine passing tests, identity check passed, a 79.4 MiB WAR upload, Ansible `ok=25 changed=15 failed=0`, and 10 database users. Build #1's eighth-test outcome and the destroy-plan summary were not captured. The destroy apply reportedly removed 24 resources, followed by bounded empty Terraform state and EC2/NAT/EIP/EBS checks in `us-east-1`; this is not a full account inventory or billing verification. The eighth-test plugin inventory and Manage Jenkins warning state were not checked. See [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md) for the full checkpoint and limits.

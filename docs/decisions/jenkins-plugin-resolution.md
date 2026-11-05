# Decision: Resolve Jenkins plugin dependencies to the latest compatible versions

**Status:** Implemented in PR #135, merged at `50b3172`; one subsequent Jenkins boot and build are reported. This decision covers plugin dependency resolution only. Jenkins core remains pinned at 2.580.1, and its separate security advisory has not been addressed.

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
- **Upgrade Jenkins core:** separate from plugin resolution and requires its own proposal, approval, and boot test; not performed here.

The chosen behavior reduces staleness in dependency resolution but accepts version drift across boots. The sixth-test response had 60 plugin names; the seventh-test response had 63, with three additional names (`jackson-annotations2-api`, `jakarta-xml-bind-api`, and `woodstox-core-api`) and 47 changed versions among the 60 shared names. These are differences between two snapshots, not proof that the flag alone caused every version change; available metadata and time also differ. The full snapshots are in [NOTES.md](../../NOTES.md#sixth-test-resolved-jenkins-plugin-inventory) and [NOTES.md](../../NOTES.md#seventh-test-resolved-jenkins-plugin-inventory).

## Separate Jenkins core advisory

The supplied, authorized official-source research identified the Jenkins core advisory dated 2026-10-28 and reported LTS 2.580.2 and weekly 2.588 as fixed versions. It also reported that 2.580.2 covers the issues in the advisory, has no notable upgrade-note requirements, and lists JDK 21 among tested configurations. The Debian stable package metadata was reported to contain `jenkins=2.580.2`. The source URLs were not retained in the supplied conversation. No core upgrade was approved, applied, or tested; 2.580.1 remains the configured pin. The setup-based exploitability comments were inferences, not exploitability tests, and do not clear the core version.

## Evidence limits

The Build #2 output, boot logs, UI warning state, saved-plan summary, and teardown checks were reported in the supplied conversation and were not independently checked for this record. The seventh-test result reports Maven `BUILD SUCCESS`, identity check passed, a 79.4 MiB WAR upload, Ansible `ok=25 changed=16 failed=0`, and 10 database users. The destroy apply reportedly removed 24 resources, followed by bounded empty Terraform state and EC2/NAT/EIP/EBS checks in `us-east-1`; this is not a full account inventory or billing verification. See [PROGRESS-HISTORY.md](../../PROGRESS-HISTORY.md) for the full checkpoint and limits.

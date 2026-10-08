# cicd-pipeline-vprofile

A learning project (Project 3 of 5 in an AWS DevOps portfolio): design and build a CI/CD pipeline that builds the VProfile reference application and delivers it to a Terraform-managed AWS target.

## Status

Phase 1 (GitHub Actions, build and test only) is working. The `Build and test` workflow runs on `pull_request`, `push` to `main`, and `workflow_dispatch`. It builds the pinned VProfile source with Maven through `scripts/build.sh`, which is designed to fail unless Maven reports at least one test run. It has no AWS access. `main` is protected by a ruleset that requires the `build-test` check.

Not done: Jenkins, AWS infrastructure and deployment, and rollback testing. This README is updated only as work is built and verified.

## Planned scope

1. GitHub Actions: build and test the application (first milestone).
2. AWS deployment design and cost approval, then deployment.
3. Jenkins: the same build and deployment flow, run from Jenkins.

## Source and attribution

VProfile is an instructor-provided reference application from the Decoding DevOps course. It is not written by the author of this repository. The source is included as the pinned Git submodule `vprofile-src`, which points to the fork `dmncfrncsc/vprofile-project`; that fork is reported to derive from `hkhcoder/vprofile-project`, but this has not been independently verified.

**Source-use permission is unresolved.** No license file was found in the source repository, and the course terms were not checked. This repository therefore contains only the author's own pipeline code, infrastructure code, and documentation. Built application artifacts (WAR files) are kept in private storage and are not published here.

## Repository documents

- `PROGRESS.md`: current state, decisions, and next steps.
- `NOTES.md`: learning guide organized by project step.

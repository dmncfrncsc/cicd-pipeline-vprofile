# cicd-pipeline-vprofile

A learning project (Project 3 of 5 in an AWS DevOps portfolio): design and build a CI/CD pipeline that builds the VProfile reference application and delivers it to a Terraform-managed AWS target.

## Status

Early planning stage. Only the repository skeleton exists. No pipeline, infrastructure, or deployment has been implemented yet. This README will be updated only as work is built and verified.

## Planned scope

1. GitHub Actions: build and test the application (first milestone).
2. AWS deployment design and cost approval, then deployment.
3. Jenkins: the same build and deployment flow, run from Jenkins.

## Source and attribution

VProfile is an instructor-provided reference application from the Decoding DevOps course. It is not written by the author of this repository. The source is planned to be included as a pinned Git submodule of a fork (`dmncfrncsc/proton`, forked from `hkhcoder/vprofile-project`).

**Source-use permission is unresolved.** No license file was found in the source repository, and the course terms were not checked. This repository therefore contains only the author's own pipeline code, infrastructure code, and documentation. Built application artifacts (WAR files) are kept in private storage and are not published here.

## Repository documents

- `PROGRESS.md`: current state, decisions, and next steps.
- `NOTES.md`: chronological learning notes.

# cicd-pipeline-vprofile

Project 3 of an AWS DevOps portfolio. The repository automates build, test, and
deployment workflows around the course-provided VProfile application; the
application itself was not authored here.

## What it demonstrates

- GitHub Actions build and test checks for pull requests and pushes; deployment is
  manual and kept separate from public pull-request workflows.
- Jenkins deployment using the same build script and Ansible playbook as the
  GitHub Actions deployment workflow.
- AWS infrastructure managed with Terraform, private instance access through
  Systems Manager, and application deployment/configuration with Ansible.
- Recorded successful deployment runs on both platforms and intentional-failure
  recovery checks that restore the same application build.

## Architecture

Terraform defines durable and temporary AWS resources. Jenkins runs on an EC2
controller and agent; the deployment playbook configures the target and checks
application and backend health. Both deployment pipelines build the WAR locally,
upload it to the private versioned S3 bucket, and deploy the local copy; neither
reads the WAR back from S3. Public pull-request workflows do not receive AWS
deployment credentials.

## Verification and limits

The shared build script runs Maven tests and checks that the WAR exists. Both
platforms have reported successful deployments and same-app failure recovery.
The Project 3 records describe the evidence and its limits, including that recovery
was tested with the same WAR; a distinct-release rollback is not claimed.

A one-off JaCoCo report measured the instructor-provided application's tests, not
the CI/CD pipeline. It was not retained or added to CI. AWS inventory, billing,
and teardown results are dated and bounded; they are not proof of current account
state or zero charges.

The 2026-11-07 S3 Versions view reportedly showed 15 WAR versions, and a download
through the root console was reported. It was not tied to a specific version and
does not demonstrate least-privilege retrieval. The artifact acceptance scope is
narrowed to private versioned storage and non-root pipeline upload; retrieval of a
named version by a non-root identity remains unproven and is a documented
limitation.

The course-provided application and built WAR are not distributed publicly. Keep
credentials, Terraform state, and private artifacts out of public files and logs.

## Project records

- [Project progress and Definition of Done](PROGRESS.md)
- [Dated evidence history](PROGRESS-HISTORY.md)
- [Technical notes](NOTES.md)
- [CI parity and quality review](docs/ci-parity-and-quality-review.md)
- [Architecture and design decisions](docs/decisions/)

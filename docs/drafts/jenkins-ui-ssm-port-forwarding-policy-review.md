# Jenkins UI SSM port-forwarding policy

**Status: review-only proposal; not applied, not adopted as policy, and not verified against saved AWS IAM.** The author selected `p3-terraform` as the identity to open the private Jenkins UI from WSL and chose the tight `${aws:userid}-*` session pattern. The three statement objects below are reproduced from the supplied conversation. `<ACCOUNT_ID>` remains a placeholder. The policy wrapper is included for readability; this is a fragment, not a complete replacement policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "JenkinsUiStartSessionOnTaggedInstances",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ec2:us-east-1:<ACCOUNT_ID>:instance/*",
      "Condition": {
        "StringEquals": { "ssm:resourceTag/Project": "p3-vprofile" }
      }
    },
    {
      "Sid": "JenkinsUiPortForwardingDocument",
      "Effect": "Allow",
      "Action": "ssm:StartSession",
      "Resource": "arn:aws:ssm:us-east-1::document/AWS-StartPortForwardingSession"
    },
    {
      "Sid": "JenkinsUiOwnSessionsOnly",
      "Effect": "Allow",
      "Action": [
        "ssm:TerminateSession",
        "ssm:ResumeSession",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "arn:aws:ssm:us-east-1:<ACCOUNT_ID>:session/${aws:userid}-*"
    }
  ]
}
```

## Review notes and limits

- The instance and AWS-owned document have separate `ssm:StartSession` statements because only the instance statement uses the `Project=p3-vprofile` tag condition. The AWS-owned document ARN has an empty account segment.
- The controller needs the `Project=p3-vprofile` tag for the proposed instance statement to match. This was not checked against a Terraform plan or live resource.
- AWS's [Session Manager IAM examples](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-examples.html) show this own-session resource pattern. That sample does not establish the actual caller identity, policy evaluation, or first-session result for this account.
- The local [instance-role policy package](new-account-iam-policy-package.md) contains an `SsmAgentCore` draft. This is local draft evidence only; role attachment, saved policy text, effective permissions, SSM registration, and network reachability were not verified.
- The author selected the existing NAT route to Systems Manager for planning, but controller reachability has not been tested. The supplied WSL output reports Session Manager plugin version `1.2.835.0`; an account session has not been tested. The Jenkins admin-password/bootstrap method remains open. The controller-to-agent WebSocket connection and its TCP 8080 security-group rule are separate; see the [J1 design record](../decisions/new-account-deployment-design.md).
- A prior handoff reports policy Version 5 of 5 as default. The five-version-limit statement in the supplied conversation came from assistant knowledge and was not checked in this documentation update. Do not edit, delete, or save an IAM policy based on this review copy; any future change needs separate approval.

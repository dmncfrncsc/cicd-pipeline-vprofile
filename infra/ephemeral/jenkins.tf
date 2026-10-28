# Jenkins lab hosts. Every resource in this file is off unless enable_jenkins is true.
# Jenkins-only teardown: set enable_jenkins = false and confirm the plan changes
# only resources defined in this file (no app, VPC, or NAT changes).
# IAM roles and instance profiles are NOT created here. They live in the durable
# root, and this file only takes their names.

variable "enable_jenkins" {
  type    = bool
  default = false
}

# Full commit SHA on GitHub that contains the jenkins/ folder. The boot script
# downloads casc.yaml, plugins.txt, and the Groovy hook from this commit.
variable "jenkins_config_commit" {
  type    = string
  default = ""
  validation {
    condition     = var.jenkins_config_commit == "" || can(regex("^[0-9a-f]{40}$", var.jenkins_config_commit))
    error_message = "jenkins_config_commit must be empty or a full 40-character lowercase commit SHA."
  }
}

variable "jenkins_deploy_role_name" {
  type    = string
  default = ""
  validation {
    condition     = var.jenkins_deploy_role_name == "" || can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.jenkins_deploy_role_name))
    error_message = "jenkins_deploy_role_name must be empty or a valid IAM role name."
  }
}

variable "jenkins_controller_profile_name" {
  type    = string
  default = ""
}

variable "jenkins_controller_instance_type" {
  type    = string
  default = "t3.medium"
}

# --- Security groups ---------------------------------------------------------
# No public inbound. The controller accepts port 8080 only from the agent.

resource "aws_security_group" "jenkins_controller" {
  count       = var.enable_jenkins ? 1 : 0
  name        = "p3-jenkins-controller-sg"
  description = "p3 Jenkins controller: inbound 8080 from the agent only, outbound 443 and 80"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "p3-jenkins-controller-sg" }
}

resource "aws_security_group" "jenkins_agent" {
  count       = var.enable_jenkins ? 1 : 0
  name        = "p3-jenkins-agent-sg"
  description = "p3 Jenkins agent: no inbound, outbound 443, 80, and 8080 to the controller"
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "p3-jenkins-agent-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_controller_from_agent" {
  count                        = var.enable_jenkins ? 1 : 0
  security_group_id            = aws_security_group.jenkins_controller[0].id
  referenced_security_group_id = aws_security_group.jenkins_agent[0].id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  tags                         = { Name = "p3-jenkins-controller-in-8080-from-agent" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_controller_https" {
  count             = var.enable_jenkins ? 1 : 0
  security_group_id = aws_security_group.jenkins_controller[0].id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  tags              = { Name = "p3-jenkins-controller-egress-443" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_controller_http" {
  count             = var.enable_jenkins ? 1 : 0
  security_group_id = aws_security_group.jenkins_controller[0].id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  tags              = { Name = "p3-jenkins-controller-egress-80" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_agent_https" {
  count             = var.enable_jenkins ? 1 : 0
  security_group_id = aws_security_group.jenkins_agent[0].id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  tags              = { Name = "p3-jenkins-agent-egress-443" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_agent_http" {
  count             = var.enable_jenkins ? 1 : 0
  security_group_id = aws_security_group.jenkins_agent[0].id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  tags              = { Name = "p3-jenkins-agent-egress-80" }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_agent_to_controller" {
  count                        = var.enable_jenkins ? 1 : 0
  security_group_id            = aws_security_group.jenkins_agent[0].id
  referenced_security_group_id = aws_security_group.jenkins_controller[0].id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  tags                         = { Name = "p3-jenkins-agent-egress-8080-to-controller" }
}

# --- Controller instance -----------------------------------------------------

resource "aws_instance" "jenkins_controller" {
  count                  = var.enable_jenkins ? 1 : 0
  ami                    = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
  instance_type          = var.jenkins_controller_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.jenkins_controller[0].id]
  iam_instance_profile   = var.jenkins_controller_profile_name

  associate_public_ip_address = false

  # Terraform puts the shebang and the two values above the boot script.
  # Both values are validated above to contain only safe characters. No secret goes here.
  user_data = join("\n", [
    "#!/bin/bash",
    "CONFIG_COMMIT='${var.jenkins_config_commit}'",
    "DEPLOY_ROLE_NAME='${var.jenkins_deploy_role_name}'",
    replace(file("${path.module}/files/jenkins-controller-boot.sh"), "\r", ""),
  ])
  user_data_replace_on_change = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  # These tags override the provider default Project tag for this instance only.
  tags = {
    Name    = "p3-jenkins-controller"
    Project = "p3-vprofile-jenkins"
    Role    = "jenkins-controller"
  }

  lifecycle {
    precondition {
      condition = (
        var.jenkins_config_commit != "" &&
        var.jenkins_deploy_role_name != "" &&
        var.jenkins_controller_profile_name != ""
      )
      error_message = "With enable_jenkins = true, set jenkins_config_commit, jenkins_deploy_role_name, and jenkins_controller_profile_name."
    }
  }

  depends_on = [
    aws_nat_gateway.main,
    aws_route_table_association.private,
    aws_vpc_security_group_egress_rule.jenkins_controller_https,
    aws_vpc_security_group_egress_rule.jenkins_controller_http,
  ]

}

output "jenkins_controller_instance_id" {
  value = one(aws_instance.jenkins_controller[*].id)
}

# --- Agent instance ----------------------------------------------------------

variable "jenkins_agent_profile_name" {
  type    = string
  default = ""
}

variable "jenkins_agent_instance_type" {
  type    = string
  default = "t3.medium"
}

resource "aws_instance" "jenkins_agent" {
  count                  = var.enable_jenkins ? 1 : 0
  ami                    = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
  instance_type          = var.jenkins_agent_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.jenkins_agent[0].id]
  iam_instance_profile   = var.jenkins_agent_profile_name

  associate_public_ip_address = false

  # Terraform puts the shebang and the controller's private IP above the boot script.
  # The IP is an address Terraform produced. No secret goes here.
  user_data = join("\n", [
    "#!/bin/bash",
    "CONTROLLER_IP='${aws_instance.jenkins_controller[0].private_ip}'",
    replace(file("${path.module}/files/jenkins-agent-boot.sh"), "\r", ""),
  ])
  user_data_replace_on_change = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  # These tags override the provider default Project tag for this instance only.
  tags = {
    Name    = "p3-jenkins-agent"
    Project = "p3-vprofile-jenkins"
    Role    = "jenkins-agent"
  }

  lifecycle {
    precondition {
      condition     = var.jenkins_agent_profile_name != ""
      error_message = "With enable_jenkins = true, set jenkins_agent_profile_name."
    }
  }

  depends_on = [
    aws_nat_gateway.main,
    aws_route_table_association.private,
    aws_vpc_security_group_egress_rule.jenkins_agent_https,
    aws_vpc_security_group_egress_rule.jenkins_agent_http,
    aws_vpc_security_group_egress_rule.jenkins_agent_to_controller,
  ]

}

output "jenkins_agent_instance_id" {
  value = one(aws_instance.jenkins_agent[*].id)
}
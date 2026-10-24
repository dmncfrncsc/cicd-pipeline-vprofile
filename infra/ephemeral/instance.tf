variable "instance_profile_name" {
  type    = string
  default = "p3-vprofile-instance-profile"
}

# Canonical's public parameter holds the current Ubuntu 24.04 AMI ID.
data "aws_ssm_parameter" "ubuntu_ami" {
  name            = "/aws/service/canonical/ubuntu/server/noble/stable/current/amd64/hvm/ebs-gp3/ami-id"
  with_decryption = false
}

resource "aws_instance" "app" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  iam_instance_profile   = var.instance_profile_name

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

  tags = { Name = "p3-vprofile-app" }
}

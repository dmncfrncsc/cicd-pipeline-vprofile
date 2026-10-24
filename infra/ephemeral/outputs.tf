output "instance_id" {
  value = aws_instance.app.id
}

output "ami_id" {
  value = nonsensitive(data.aws_ssm_parameter.ubuntu_ami.value)
}

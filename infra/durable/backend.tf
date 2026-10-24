terraform {
  backend "s3" {
    bucket       = "p3-vprofile-tfstate-r5w8n2"
    key          = "durable/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

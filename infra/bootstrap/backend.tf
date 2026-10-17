terraform {
  backend "s3" {
    bucket       = "p3-vprofile-tfstate-x4b8t3"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-east-1"
    profile      = "p3-terraform"
    encrypt      = true
    use_lockfile = true
  }
}

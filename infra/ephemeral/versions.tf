terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "p3-vprofile-tfstate-r5w8n2"
    key          = "ephemeral/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  # Every resource gets this tag. Many IAM policy statements require it.
  default_tags {
    tags = {
      Project = "p3-vprofile"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "war" {
  bucket = "p3-vprofile-war-k7m3q9"

  tags = {
    Project = "p3"
  }
}

resource "aws_s3_bucket_versioning" "war" {
  bucket = aws_s3_bucket.war.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "war" {
  bucket = aws_s3_bucket.war.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "war" {
  bucket = aws_s3_bucket.war.id

  rule {
    id     = "expire-old-war-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket" "ansible_transfer" {
  bucket = "p3-vprofile-ansible-transfer-k7m3q9"

  tags = {
    Project = "p3"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible_transfer" {
  bucket = aws_s3_bucket.ansible_transfer.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "war" {
  bucket = "p3-vprofile-war-k7q2m9"

  tags = {
    Project = "p3"
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

resource "aws_s3_bucket_public_access_block" "war" {
  bucket = aws_s3_bucket.war.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "war" {
  bucket = aws_s3_bucket.war.id

  rule {
    id     = "expire-wars-after-30-days"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "war_https_only" {
  bucket = aws_s3_bucket.war.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.war.arn,
          "${aws_s3_bucket.war.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "ansible" {
  bucket = "p3-vprofile-ansible-h6n5w2"

  tags = {
    Project = "p3"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ansible" {
  bucket = aws_s3_bucket.ansible.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ansible" {
  bucket = aws_s3_bucket.ansible.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "ansible" {
  bucket = aws_s3_bucket.ansible.id

  rule {
    id     = "expire-transfer-files-after-1-day"
    status = "Enabled"

    filter {}

    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_policy" "ansible_https_only" {
  bucket = aws_s3_bucket.ansible.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.ansible.arn,
          "${aws_s3_bucket.ansible.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

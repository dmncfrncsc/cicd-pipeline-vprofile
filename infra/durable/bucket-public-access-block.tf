# Block all public access on both private buckets.
# The WAR is never distributed publicly, so this is a second guard against a
# public ACL or public bucket policy being added by mistake.

resource "aws_s3_bucket_public_access_block" "war" {
  bucket = aws_s3_bucket.war.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "ansible_transfer" {
  bucket = aws_s3_bucket.ansible_transfer.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

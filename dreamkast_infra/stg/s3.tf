# ------------------------------------------------------------#
# S3 Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.prj_prefix}-${var.s3_bucket_name}"

  tags = {
    Name = "${var.prj_prefix}-${var.s3_bucket_name}"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://github.com/cloudnativedaysjp/dreamkast/issues/1243
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "delete_shrine_cache"
    status = "Enabled"

    filter {
      prefix = "cache/avatar/"
    }
    expiration {
      days = 7
    }
  }

}

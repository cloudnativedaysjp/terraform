# ------------------------------------------------------------#
# S3 Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.prj_prefix}-${var.s3_bucket_name}"

  tags = {
    Name = "${var.prj_prefix}-${var.s3_bucket_name}"
  }
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


# ------------------------------------------------------------#
#  Archiveデータ削減のためのライフサイクル
# ------------------------------------------------------------#
data "aws_s3_bucket" "archive" {
  provider = aws.ap-northeast-1
  bucket   = "dreamkast-archive-stg"
}

resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  provider = aws.ap-northeast-1
  bucket   = data.aws_s3_bucket.archive.id
  rule {
    id     = "ArchiveObjectRule"
    status = "Enabled"
    expiration {
      expired_object_delete_marker = true
    }
  }
}

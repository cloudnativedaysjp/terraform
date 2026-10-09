# ------------------------------------------------------------#
# S3 Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.prj_prefix}-bucket"

  tags = {
    Name = "${var.prj_prefix}-bucket"
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

  # Shrine の cache ストレージ (prefix: cache/) は一時置き場。
  # avatar / sponsor_attachment などすべての Uploader の cache が対象。
  rule {
    id     = "delete_shrine_cache"
    status = "Enabled"

    filter {
      prefix = "cache/"
    }
    expiration {
      days = 7
    }
  }

  # 講演動画の Uppy マルチパートアップロード (video_file/) で中断されたものを掃除する。
  # アプリ側のアップロード有効期限は 24 時間 (MultipartUploadsController)。
  rule {
    id     = "abort_incomplete_multipart_upload"
    status = "Enabled"

    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# ------------------------------------------------------------#
# S3 Bucket for ALB access logs
# ------------------------------------------------------------#
resource "aws_s3_bucket" "alb_log" {
  bucket = "${var.prj_prefix}-alb-log"

  tags = {
    Name = "${var.prj_prefix}-alb-log"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    # AWS 側で既定になった SSE-C のブロックに合わせる（未指定だと SSE-C を許可する差分が出る）
    blocked_encryption_types = ["SSE-C"]

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    id     = "delete_old_logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_log.arn}/alb/AWSLogs/${var.aws_account_id}/*"]
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

# ------------------------------------------------------------#
# S3 Bucket for Athena query results
# ------------------------------------------------------------#
resource "aws_s3_bucket" "athena_query_results" {
  bucket = "${var.prj_prefix}-athena-query-results"

  tags = {
    Name = "${var.prj_prefix}-athena-query-results"
  }
}

resource "aws_s3_bucket_public_access_block" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id

  rule {
    # AWS 側で既定になった SSE-C のブロックに合わせる（未指定だと SSE-C を許可する差分が出る）
    blocked_encryption_types = ["SSE-C"]

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_query_results" {
  bucket = aws_s3_bucket.athena_query_results.id

  rule {
    id     = "delete_old_query_results"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

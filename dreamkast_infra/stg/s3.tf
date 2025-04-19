# ------------------------------------------------------------#
# S3 Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.prj_prefix}-bucket"

  tags = {
    Name = "${var.prj_prefix}-bucket"
    #Environment = "${var.prj_prefix}"
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
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}

# ------------------------------------------------------------#
# OpenTelemetry Collector Config Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "otelcol_config" {
  bucket = "dreamkast-otelcol-config-stg"

  tags = {
    Name = "dreamkast-otelcol-config-stg"
  }
}

resource "aws_s3_bucket_public_access_block" "otelcol_config_block" {
  bucket = aws_s3_bucket.otelcol_config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ECSからのアクセスを許可
resource "aws_s3_bucket_policy" "otelcol_config_policy" {
  bucket = aws_s3_bucket.otelcol_config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowECSAccess"
        Effect    = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.otelcol_config.arn,
          "${aws_s3_bucket.otelcol_config.arn}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_ecs_cluster.dreamkast_stg.arn
          }
        }
      }
    ]
  })
}

# ECSタスク実行ロールにS3アクセス権限を付与する
resource "aws_iam_policy" "ecs_s3_otelcol_config_access" {
  name        = "dreamkast-stg-ecs-s3-otelcol-config-access"
  description = "Allow ECS tasks to access OpenTelemetry config in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.otelcol_config.arn,
          "${aws_s3_bucket.otelcol_config.arn}/*"
        ]
      }
    ]
  })
}

# GitHub Actions用のIAMユーザー
resource "aws_iam_user" "github_actions_otelcol" {
  name = "github-actions-otelcol-config-stg"
}

# GitHub Actions用のアクセスポリシー
resource "aws_iam_user_policy" "github_actions_s3_otelcol_access" {
  name = "github-actions-s3-otelcol-config-access"
  user = aws_iam_user.github_actions_otelcol.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.otelcol_config.arn,
          "${aws_s3_bucket.otelcol_config.arn}/*"
        ]
      }
    ]
  })
}

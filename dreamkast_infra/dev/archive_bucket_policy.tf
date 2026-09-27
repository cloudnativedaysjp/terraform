# ------------------------------------------------------------#
#  アーカイブ用 S3 バケット（us-west-2）のバケットポリシー
#  - CloudFront(OAI) からの読み取り
#  - MediaPackage V2 の HarvestJob からの書き込み（アーカイブ動画の切り出し）
#  バケット自体は Terraform 管理外。ポリシーのみ import して管理する
# ------------------------------------------------------------#
locals {
  archive_us_west_2_bucket = "dreamkast-archive-dev-us-west-2"
}

# 既存のバケットポリシーを Terraform 管理下に取り込むための import ブロック。
# 初回 apply 後はそのまま残しても害は無いが、削除しても問題ない。
import {
  to = aws_s3_bucket_policy.archive_us_west_2
  id = "dreamkast-archive-dev-us-west-2"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "archive_us_west_2" {
  policy_id = "PolicyForCloudFrontPrivateContent"

  statement {
    sid    = "1"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E4PUWUUECHC3O"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.archive_us_west_2_bucket}/*"]
  }

  # 手動で追加されていた条件なしの許可を、SourceAccount 条件付きに置き換える
  statement {
    sid    = "AllowMediaPackageV2HarvestJob"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["mediapackagev2.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.archive_us_west_2_bucket}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "archive_us_west_2" {
  bucket = local.archive_us_west_2_bucket
  policy = data.aws_iam_policy_document.archive_us_west_2.json
}

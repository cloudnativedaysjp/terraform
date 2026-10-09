# ------------------------------------------------------------#
#  アーカイブ動画用 S3 バケットのライフサイクル
#  - 過去イベントの HLS アーカイブは大半がほぼ参照されないため、
#    Intelligent-Tiering に移して保管料をアクセス頻度に応じて自動で下げる
#    (取り出し料金・最低保存期間なし。128KB 未満のオブジェクトは移行対象外)
#  - バケット自体は Terraform 管理外。ライフサイクル設定のみ管理する
#
#  NOTE: aws_s3_bucket_lifecycle_configuration はバケットのライフサイクル設定を丸ごと置き換える。
#        apply 前に既存設定が無いことを確認すること:
#        aws s3api get-bucket-lifecycle-configuration --bucket <bucket>
# ------------------------------------------------------------#
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

locals {
  archive_lifecycle_rule_id = "transition_to_intelligent_tiering"
}

# cndt2021 / cnsec2022 / o11y2022 / cndt2022 (medialive) / cicd2023 / cndf2023 (mediapackage, medialive)
resource "aws_s3_bucket_lifecycle_configuration" "archive_us_east_1" {
  provider = aws.us-east-1
  bucket   = "dreamkast-ivs-stream-archive-prd"

  rule {
    id     = local.archive_lifecycle_rule_id
    status = "Enabled"

    filter {}
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

# cndt2022 / cicd2023 / cndf2023
resource "aws_s3_bucket_lifecycle_configuration" "archive_ap_northeast_1" {
  bucket = "dreamkast-archive-prd"

  rule {
    id     = local.archive_lifecycle_rule_id
    status = "Enabled"

    filter {}
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
    # このバケットのみバージョニングが有効なため、旧バージョンも同様に移行する
    noncurrent_version_transition {
      noncurrent_days = 1
      storage_class   = "INTELLIGENT_TIERING"
    }
  }
}

# cndt2023 以降 (MediaPackage V2 HarvestJob の出力先)
resource "aws_s3_bucket_lifecycle_configuration" "archive_us_west_2" {
  provider = aws.us-west-2
  bucket   = local.archive_us_west_2_bucket

  rule {
    id     = local.archive_lifecycle_rule_id
    status = "Enabled"

    filter {}
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

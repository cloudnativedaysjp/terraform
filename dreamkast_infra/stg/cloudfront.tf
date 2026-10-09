# ライブ配信用 CloudFront Distribution (Terraform 管理外) の MediaPackage V2 向け
# Behavior が使うキャッシュポリシー。dreamkast アプリが名前で検索して参照している
# (app/models/media_package_v2_origin_endpoint.rb#cache_policy_name) ため、名前の変更・削除は不可。
#
# Cookie や MediaPackage が解釈しないクエリ文字列をキャッシュキーに含めるとセグメントのキャッシュが視聴者ごとに
# 分散し、オリジン (MediaPackage V2) へのリクエストが増えるため、Cookie は含めず、
# クエリ文字列は MediaPackage V2 / LL-HLS が解釈するものだけに絞る。
# 許可リストは prod/cloudfront.tf と stg/cloudfront.tf で揃えること。
resource "aws_cloudfront_cache_policy" "for_mediapackage_v2" {
  name        = "MediaPackageV2_stg"
  comment     = ""
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = false
    enable_accept_encoding_brotli = false
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Origin",
          "Access-Control-Request-Method",
          "Access-Control-Allow-Origin",
          "Access-Control-Request-Header"
        ]
      }
    }
    cookies_config {
      cookie_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = [
          # LL-HLS のブロッキングプレイリストリロード / デルタ更新
          "_HLS_msn",
          "_HLS_part",
          "_HLS_skip",
          # MediaPackage のタイムシフト・マニフェストフィルタ
          "start",
          "end",
          "aws.manifestfilter",
          "aws.manifestsettings",
        ]
      }
    }
  }
}

resource "aws_cloudfront_cache_policy" "for_mediapackage_v2_manifest" {
  name        = "MediaPackageV2_manifest_stg"
  comment     = ""
  min_ttl     = 0
  default_ttl = 5
  max_ttl     = 10
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = false
    enable_accept_encoding_brotli = false
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Origin",
          "Access-Control-Request-Method",
          "Access-Control-Allow-Origin",
          "Access-Control-Request-Header"
        ]
      }
    }
    cookies_config {
      cookie_behavior = "all"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "for_mediapackage_v2_segment" {
  name        = "MediaPackageV2_segment_stg"
  comment     = ""
  min_ttl     = 0
  default_ttl = 86400
  max_ttl     = 86400
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = false
    enable_accept_encoding_brotli = false
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = [
          "Origin",
          "Access-Control-Request-Method",
          "Access-Control-Allow-Origin",
          "Access-Control-Request-Header"
        ]
      }
    }
    cookies_config {
      cookie_behavior = "all"
    }
    query_strings_config {
      query_string_behavior = "all"
    }
  }
}
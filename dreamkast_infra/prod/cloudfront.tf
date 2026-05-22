# ============================================================
# Cache Policies
# ============================================================
# 既存リソース。現在 Distribution からは参照されていない（孤児状態）。
# 将来の利用に備えてそのまま残す。
resource "aws_cloudfront_cache_policy" "for_mediapackage_v2" {
  name        = "MediaPackageV2_prd"
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
          "Access-Control-Request-Headers"
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

resource "aws_cloudfront_cache_policy" "for_mediapackage_v2_manifest" {
  name        = "MediaPackageV2_manifest_prd"
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
          "Access-Control-Request-Headers"
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
  name        = "MediaPackageV2_segment_prd"
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
          "Access-Control-Request-Headers"
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

# ============================================================
# Response Headers Policy
# ============================================================
# Video.js から HLS を取得する際、CloudFront が生成するエラー応答
# (4xx/5xx) や Origin Shield 経由で取得した一部応答に CORS ヘッダーが
# 付かず "CORS error" として失敗する事象への対策。
# origin_override = true により、オリジンが返すヘッダーより本ポリシーを
# 優先して必ず CORS ヘッダーを付与する。
resource "aws_cloudfront_response_headers_policy" "video_archive_cors" {
  name    = "VideoArchive_cors_prd"
  comment = "Force CORS headers for HLS playback (m3u8/ts)"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = ["*"]
    }
    access_control_expose_headers {
      items = ["*"]
    }

    access_control_max_age_sec = 600
    origin_override            = true
  }
}

# ============================================================
# CloudFront Distribution
# ============================================================
# 既存の Distribution を Terraform 管理下に取り込むための import ブロック。
# 初回 apply 後はそのまま残しても害は無いが、削除しても問題ない。
import {
  to = aws_cloudfront_distribution.video_archive
  id = "E2V1HG837A3V4G"
}

# Managed policies:
#   62cadc5a-199b-46f5-aed1-5928b21e890e = Managed-CachingOptimizedForUncompressedObjects 系 (CachingOptimizedCORS)
#   88a5eaf4-2fd4-4709-b370-b4c650ea3fcf = Managed-CORS-S3Origin
locals {
  managed_cache_policy_caching_optimized_cors = "62cadc5a-199b-46f5-aed1-5928b21e890e"
  managed_origin_request_policy_cors_s3       = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

  origin_s3_useast1      = "dreamkast-ivs-stream-archive-prd.s3.us-east-1.amazonaws.com"
  origin_s3_apnortheast1 = "dreamkast-archive-prd.s3.ap-northeast-1.amazonaws.com"
  origin_s3_uswest2      = "dreamkast-archive-prd-us-west-2.s3.us-west-2.amazonaws.com"

  origin_access_identity = "origin-access-identity/cloudfront/E4PUWUUECHC3O"
}

resource "aws_cloudfront_distribution" "video_archive" {
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
  price_class     = "PriceClass_All"
  comment         = "For video archive distribution (prd)"

  # ---------- Origins ----------
  origin {
    origin_id   = local.origin_s3_useast1
    domain_name = local.origin_s3_useast1

    s3_origin_config {
      origin_access_identity = local.origin_access_identity
    }

    connection_attempts = 3
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = "ap-northeast-1"
    }
  }

  origin {
    origin_id   = local.origin_s3_apnortheast1
    domain_name = local.origin_s3_apnortheast1

    s3_origin_config {
      origin_access_identity = local.origin_access_identity
    }

    connection_attempts = 3
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = "ap-northeast-1"
    }
  }

  origin {
    origin_id   = local.origin_s3_uswest2
    domain_name = local.origin_s3_uswest2

    s3_origin_config {
      origin_access_identity = local.origin_access_identity
    }

    connection_attempts = 3
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = "ap-northeast-1"
    }
  }

  # ---------- Default cache behavior ----------
  default_cache_behavior {
    target_origin_id       = local.origin_s3_apnortheast1
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    compress               = true

    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  # ---------- Ordered cache behaviors ----------
  # 評価順は API レスポンスと同じ並びを維持すること。順序を変えると plan に差分が出る。
  ordered_cache_behavior {
    path_pattern               = "*cnsec2022*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*o11y2022*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cndt2021*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*medialive/cndt2022/*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cndt2022*"
    target_origin_id           = local.origin_s3_apnortheast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*mediapackage/cicd2023/*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*medialive/cicd2023/*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cicd2023*"
    target_origin_id           = local.origin_s3_apnortheast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*mediapackage/cndf2023/*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*medialive/cndf2023/*"
    target_origin_id           = local.origin_s3_useast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cndf2023*"
    target_origin_id           = local.origin_s3_apnortheast1
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cndt2023*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cnds2024*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  # *cndw2024* だけ origin_request_policy が未設定（既存設定をそのまま再現）
  ordered_cache_behavior {
    path_pattern               = "*cndw2024*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cnds2025*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cndw2025*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  ordered_cache_behavior {
    path_pattern               = "*cnk*"
    target_origin_id           = local.origin_s3_uswest2
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    compress                   = true
    cache_policy_id            = local.managed_cache_policy_caching_optimized_cors
    origin_request_policy_id   = local.managed_origin_request_policy_cors_s3
    response_headers_policy_id = aws_cloudfront_response_headers_policy.video_archive_cors.id
  }

  # ---------- Custom error responses ----------
  # CloudFront が生成するエラー応答 (オリジン接続失敗・タイムアウト・404 等) は
  # CORS ヘッダーを持たない。デフォルトの 300 秒キャッシュにより、一度発生すると
  # 5 分間ブラウザに CORS error として返り続けるため、最小値 (1 秒) に短縮する。
  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 1
  }
  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 1
  }
  custom_error_response {
    error_code            = 500
    error_caching_min_ttl = 1
  }
  custom_error_response {
    error_code            = 502
    error_caching_min_ttl = 1
  }
  custom_error_response {
    error_code            = 503
    error_caching_min_ttl = 1
  }
  custom_error_response {
    error_code            = 504
    error_caching_min_ttl = 1
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

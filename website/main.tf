terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "website"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "cloudnativedaysjp-website"
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.static-www.json
}

data "aws_iam_policy_document" "static-www" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static-www.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_cloudfront_distribution" "static-www" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static-www.cloudfront_access_identity_path
    }
  }

  aliases = ["cloudnativedays.jp"]

  enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "JP"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cloudnativedaysjp.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_identity" "static-www" {}

resource "aws_route53_record" "cloudnativedaysjp_alias" {
  name    = "cloudnativedays.jp"
  type            = "A"
  zone_id         = data.aws_route53_zone.cloudnativedaysjp.zone_id
  alias {
    name                   = aws_cloudfront_distribution.static-www.domain_name
    zone_id                = aws_cloudfront_distribution.static-www.hosted_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect-to-index"
  runtime = "cloudfront-js-1.0"
  comment = "Redirect access to index.html"
  publish = true
  code    = file("redirect.js")
}

resource "aws_acm_certificate" "cloudnativedaysjp" {
  domain_name       = "cloudnativedays.jp"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "cloudnativedaysjp" {
  name         = "cloudnativedays.jp"
  private_zone = false
}

resource "aws_route53_record" "cloudnativedaysjp" {
  for_each = {
    for dvo in aws_acm_certificate.cloudnativedaysjp.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cloudnativedaysjp.zone_id
}

resource "aws_acm_certificate_validation" "cloudnativedaysjp" {
  certificate_arn         = aws_acm_certificate.cloudnativedaysjp.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudnativedaysjp : record.fqdn]
}
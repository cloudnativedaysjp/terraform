resource "aws_acm_certificate" "wildcard_dev_cloudnativedays_jp" {
  domain_name       = "*.dev.cloudnativedays.jp"
  validation_method = "DNS"

  subject_alternative_names = [
    "dev.cloudnativedays.jp"
  ]

  lifecycle {
    create_before_destroy = true
  }

  #tags = {
  #  Environment = "${var.common_prefix}"
  #}
}

resource "aws_route53_record" "validate_wildcard_dev_cloudnativedays_jp" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_dev_cloudnativedays_jp.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "30"

  zone_id = data.aws_route53_zone.cloudnativedays_jp.zone_id
}

resource "aws_acm_certificate_validation" "wildcard_dev_cloudnativedays_jp" {
  certificate_arn = aws_acm_certificate.wildcard_dev_cloudnativedays_jp.arn

  depends_on = [
    aws_route53_record.validate_wildcard_dev_cloudnativedays_jp
  ]
}

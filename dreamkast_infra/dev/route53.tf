data "aws_route53_zone" "cloudnativedays_jp" {
  name = "cloudnativedays.jp"
}

resource "aws_route53_record" "wildcard_dev_cloudnativedays_jp" {
  zone_id = data.aws_route53_zone.cloudnativedays_jp.zone_id
  name    = "*.dev.cloudnativedays.jp"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

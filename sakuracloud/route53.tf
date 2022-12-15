data "aws_route53_zone" "cloudnativedays" {
  name         = "cloudnativedays.jp."
  private_zone = false
}

resource "aws_route53_record" "sentry" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "sentry.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.sentry.ip_address]
}

resource "aws_route53_record" "elk" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "elk.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.elk.ip_address]
}

resource "aws_route53_record" "nc_sandbox_internal" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "nc-sandbox-internal.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = ["192.168.71.112"]
}

data "aws_route53_zone" "cloudnativedays" {
  name         = "cloudnativedays.jp."
  private_zone = false
}

resource "aws_route53_record" "loki" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.loki.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.o11y_stacks.ip_address]
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.prometheus.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.o11y_stacks.ip_address]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.grafana.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.o11y_stacks.ip_address]
}

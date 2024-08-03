data "aws_route53_zone" "cloudnativedays" {
  name         = "cloudnativedays.jp."
  private_zone = false
}

resource "aws_route53_record" "loki" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.loki.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.loki.ip_address]
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.prometheus.sakura.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.prometheus.ip_address]
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "stg.grafana.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.grafana.ip_address]
}

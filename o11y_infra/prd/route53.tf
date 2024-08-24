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

resource "aws_route53_record" "loki" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "loki.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.loki.ip_address]
}

resource "aws_route53_record" "prometheus" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "prometheus.sakura.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.prometheus.ip_address]
}

# todo: EKS側Grafanaに向かなくなったタイミングでsakuraに向ける
# resource "aws_route53_record" "grafana" {
#   zone_id = data.aws_route53_zone.cloudnativedays.zone_id
#   name    = "grafana.cloudnativedays.jp"
#   type    = "A"
#   ttl     = "300"
#   records = [sakuracloud_server.grafana.ip_address]
# }

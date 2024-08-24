data "aws_route53_zone" "cloudnativedays" {
  name         = "cloudnativedays.jp."
  private_zone = false
}

resource "aws_route53_record" "elk" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "elk.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.elk.ip_address]
}

resource "aws_route53_record" "nc_sandbox" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "nc-sandbox.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.nc_sandbox.ip_address]
}

resource "aws_route53_record" "nc_sandbox_internal" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "nc-sandbox-internal.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = ["192.168.71.112"]
}

resource "aws_route53_record" "nextcloud_internal" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "nextcloud-internal.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = ["192.168.71.111"]
}

resource "aws_route53_record" "uploader" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "uploader.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.nextcloud.ip_address]
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.cloudnativedays.zone_id
  name    = "vault.cloudnativedays.jp"
  type    = "A"
  ttl     = "300"
  records = [sakuracloud_server.vault.ip_address]
}

data "aws_lb" "lb" {
  tags = {
    "elbv2.k8s.aws/cluster"    = var.cluster_name
    "service.k8s.aws/resource" = "LoadBalancer"
    "service.k8s.aws/stack"    = "projectcontour/envoy"
  }
}

data "aws_route53_zone" "cloudnativedays_jp" {
  name = "cloudnativedays.jp"
}

resource "aws_route53_record" "wildcard_dev_cloudnativedays_jp" {
  zone_id = data.aws_route53_zone.lb_zone.zone_id
  name    = "*.dev.cloudnativedays.jp	"
  type    = "A"
  records = [data.aws_lb.lb.dns_name]
  ttl     = 300
}

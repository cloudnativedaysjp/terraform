#data "aws_lb" "lb" {
#  tags = {
#    "elbv2.k8s.aws/cluster"    = var.cluster_name
#    "service.k8s.aws/resource" = "LoadBalancer"
#    "service.k8s.aws/stack"    = "projectcontour/envoy"
#  }
#}
#
#data "aws_route53_zone" "cloudnativedays_jp" {
#  name = "cloudnativedays.jp"
#}
#
#resource "aws_route53_record" "wildcard_cloudnativedays_jp" {
#  zone_id = data.aws_route53_zone.cloudnativedays_jp.zone_id
#  name    = "*.cloudnativedays.jp"
#  type    = "A"
#  alias {
#    name                   = data.aws_lb.lb.dns_name
#    zone_id                = data.aws_lb.lb.zone_id
#    evaluate_target_health = true
#  }
#}

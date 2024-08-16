data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.prj_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, k + length(local.azs))]
  intra_subnets   = [for k, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, k + length(local.azs)*2)]

  enable_nat_gateway     = false

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kind"                                      = "private"
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kind"                                      = "public"
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  intra_subnet_tags = {
    "kind" = "intra"
  }
}

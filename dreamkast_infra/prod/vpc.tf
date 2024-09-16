data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  vpc_cidr = "10.110.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.prj_prefix}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, _ in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, _ in local.azs : cidrsubnet(local.vpc_cidr, 4, k + length(local.azs))]
  intra_subnets   = [for k, _ in local.azs : cidrsubnet(local.vpc_cidr, 4, k + length(local.azs) * 2)]

  enable_nat_gateway = false

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

# ------------------------------------------------------------#
#  VPC Endpoints
# ------------------------------------------------------------#
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = module.vpc.private_route_table_ids
}

# ------------------------------------------------------------#
#  Service Discovery
# ------------------------------------------------------------#
resource "aws_service_discovery_private_dns_namespace" "dreamkast_production" {
  name = "production.local"
  vpc  = module.vpc.vpc_id
}

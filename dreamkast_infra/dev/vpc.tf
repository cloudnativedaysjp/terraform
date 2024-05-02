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

  ### TODO: delete the following after that
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
  ###

  #tags = {
  #  Environment = "${var.common_prefix}"
  #}
}

# ------------------------------------------------------------#
#  VPC Endpoints
# ------------------------------------------------------------#
resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.prj_prefix}-vpc-endpoint"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_vpc_endpoint" "endpoints_gateway" {
  for_each = toset([
    "s3",
  ])

  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  route_table_ids = module.vpc.private_route_table_ids

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_vpc_endpoint" "endpoints_interface" {
  for_each = toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "secretsmanager",
    "ssmmessages",
    "sqs",
  ])

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type = "Interface"

  subnet_ids         = module.vpc.intra_subnets
  security_group_ids = [aws_security_group.vpc_endpoint.id]

  private_dns_enabled = true

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
#  Service Discovery
# ------------------------------------------------------------#
resource "aws_service_discovery_private_dns_namespace" "dreamkast_development" {
  name = "development.local"
  vpc  = module.vpc.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.prj_prefix}-vpc"
  cidr = "10.110.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.110.0.0/19", "10.110.32.0/19"]
  private_subnets = ["10.110.64.0/19", "10.110.96.0/19"]
  intra_subnets   = ["10.110.128.0/19", "10.110.160.0/19"]

  public_subnet_names  = ["${var.prj_prefix}-public-subnet-a", "${var.prj_prefix}-public-subnet-b"]
  private_subnet_names = ["${var.prj_prefix}-private-subnet-a", "${var.prj_prefix}-private-subnet-b"]
  intra_subnet_names   = ["${var.prj_prefix}-intra-subnet-a", "${var.prj_prefix}-intra-subnet-b"]

  # One NAT Gateway per availability zone
  enable_nat_gateway = true
  single_nat_gateway = false

  one_nat_gateway_per_az = true

  enable_vpn_gateway = false

}

# ------------------------------------------------------------#
#  VPC
# ------------------------------------------------------------#
# resource "aws_vpc" "vpc" {
#   cidr_block           = "${var.vpc_cidr_block}"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   tags                 = {
#     Name = "${var.prj_prefix}-vpc"
#   }
# }

# ------------------------------------------------------------
# Moved Blocks
# ------------------------------------------------------------
moved {
  from = module.vpc.aws_internet_gateway.this[0]
  to   = aws_internet_gateway.this
}
moved {
  from = module.vpc.aws_route.public_internet_gateway[0]
  to   = aws_route.public_internet_gateway
}
moved {
  from = module.vpc.aws_route_table.intra[0]
  to   = aws_route_table.intra
}
moved {
  from = module.vpc.aws_route_table.private[0]
  to   = aws_route_table.private[0]
}
moved {
  from = module.vpc.aws_route_table.private[1]
  to   = aws_route_table.private[1]
}
moved {
  from = module.vpc.aws_route_table.private[2]
  to   = aws_route_table.private[2]
}
moved {
  from = module.vpc.aws_route_table.public[0]
  to   = aws_route_table.public
}
moved {
  from = module.vpc.aws_route_table_association.intra[0]
  to   = aws_route_table_association.intra[0]
}
moved {
  from = module.vpc.aws_route_table_association.intra[1]
  to   = aws_route_table_association.intra[1]
}
moved {
  from = module.vpc.aws_route_table_association.intra[2]
  to   = aws_route_table_association.intra[2]
}
moved {
  from = module.vpc.aws_route_table_association.private[0]
  to   = aws_route_table_association.private[0]
}
moved {
  from = module.vpc.aws_route_table_association.private[1]
  to   = aws_route_table_association.private[1]
}
moved {
  from = module.vpc.aws_route_table_association.private[2]
  to   = aws_route_table_association.private[2]
}
moved {
  from = module.vpc.aws_route_table_association.public[0]
  to   = aws_route_table_association.public[0]
}
moved {
  from = module.vpc.aws_route_table_association.public[1]
  to   = aws_route_table_association.public[1]
}
moved {
  from = module.vpc.aws_route_table_association.public[2]
  to   = aws_route_table_association.public[2]
}
moved {
  from = module.vpc.aws_subnet.intra[0]
  to   = aws_subnet.intra[0]
}
moved {
  from = module.vpc.aws_subnet.intra[1]
  to   = aws_subnet.intra[1]
}
moved {
  from = module.vpc.aws_subnet.intra[2]
  to   = aws_subnet.intra[2]
}
moved {
  from = module.vpc.aws_subnet.private[0]
  to   = aws_subnet.private[0]
}
moved {
  from = module.vpc.aws_subnet.private[1]
  to   = aws_subnet.private[1]
}
moved {
  from = module.vpc.aws_subnet.private[2]
  to   = aws_subnet.private[2]
}
moved {
  from = module.vpc.aws_subnet.public[0]
  to   = aws_subnet.public[0]
}
moved {
  from = module.vpc.aws_subnet.public[1]
  to   = aws_subnet.public[1]
}
moved {
  from = module.vpc.aws_subnet.public[2]
  to   = aws_subnet.public[2]
}
moved {
  from = module.vpc.aws_vpc.this[0]
  to   = aws_vpc.this
}

# ------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# ------------------------------------------------------------
# Local Variables
# ------------------------------------------------------------
locals {
  vpc_cidr = "10.110.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  # Subnet configuration
  subnet_config = {
    public = {
      cidr_offset             = 3 # Starting from 10.110.48.0/20
      map_public_ip_on_launch = true
      kind_tag                = "private" # Note: This seems backwards but matches actual state
      additional_tags = {
        "kubernetes.io/role/elb"                    = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }
    }
    private = {
      cidr_offset             = 0 # Starting from 10.110.0.0/20
      map_public_ip_on_launch = false
      kind_tag                = "public" # Note: This seems backwards but matches actual state
      additional_tags = {
        "kubernetes.io/role/internal-elb"           = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      }
    }
    intra = {
      cidr_offset             = 6 # Starting from 10.110.96.0/20
      map_public_ip_on_launch = false
      kind_tag                = "intra"
      additional_tags         = {}
    }
  }
}

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prj_prefix}-vpc"
  }
}

# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prj_prefix}-vpc"
  }
}

# ------------------------------------------------------------
# Public Subnets
# ------------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, local.subnet_config.public.cidr_offset + count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = local.subnet_config.public.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.prj_prefix}-vpc-public-${local.azs[count.index]}"
      kind = local.subnet_config.public.kind_tag
    },
    local.subnet_config.public.additional_tags
  )
}

# ------------------------------------------------------------
# Private Subnets
# ------------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, local.subnet_config.private.cidr_offset + count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = local.subnet_config.private.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.prj_prefix}-vpc-private-${local.azs[count.index]}"
      kind = local.subnet_config.private.kind_tag
    },
    local.subnet_config.private.additional_tags
  )
}

# ------------------------------------------------------------
# Intra Subnets
# ------------------------------------------------------------
resource "aws_subnet" "intra" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, local.subnet_config.intra.cidr_offset + count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = local.subnet_config.intra.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.prj_prefix}-vpc-intra-${local.azs[count.index]}"
      kind = local.subnet_config.intra.kind_tag
    },
    local.subnet_config.intra.additional_tags
  )
}

# ------------------------------------------------------------
# Public Route Table
# ------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prj_prefix}-vpc-public"
  }
}

# Public route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------------------------------------
# Private Route Tables (one per AZ)
# ------------------------------------------------------------
resource "aws_route_table" "private" {
  count = length(local.azs)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prj_prefix}-vpc-private-${local.azs[count.index]}"
  }
}

# Associate private subnets with their respective route tables
resource "aws_route_table_association" "private" {
  count = length(local.azs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ------------------------------------------------------------
# Intra Route Table
# ------------------------------------------------------------
resource "aws_route_table" "intra" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.prj_prefix}-vpc-intra"
  }
}

# Associate intra subnets with intra route table
resource "aws_route_table_association" "intra" {
  count = length(local.azs)

  subnet_id      = aws_subnet.intra[count.index].id
  route_table_id = aws_route_table.intra.id
}

# ------------------------------------------------------------#
#  VPC Endpoints
# ------------------------------------------------------------#
resource "aws_security_group" "vpc_endpoint" {
  name   = "${var.prj_prefix}-vpc-endpoint"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "allow all"
    protocol    = "-1"
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

  vpc_id          = aws_vpc.this.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  route_table_ids = aws_route_table.private[*].id

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

# ------------------------------------------------------------#
#  Service Discovery
# ------------------------------------------------------------#
resource "aws_service_discovery_private_dns_namespace" "dreamkast_development" {
  name = "development.local"
  vpc  = aws_vpc.this.id
}

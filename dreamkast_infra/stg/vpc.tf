data "aws_vpc" "dreamkast_dev_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dreamkast-dev-vpc"]
  }
}

data "aws_subnets" "dreamkast_dev_intra" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dreamkast_dev_vpc.id]
  }
  filter {
    name   = "tag:kind"
    values = ["intra"]
  }
}

data "aws_subnets" "dreamkast_dev_private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dreamkast_dev_vpc.id]
  }
  filter {
    name   = "tag:kind"
    values = ["private"]
  }
}

data "aws_subnets" "dreamkast_dev_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dreamkast_dev_vpc.id]
  }
  filter {
    name   = "tag:kind"
    values = ["public"]
  }
}

data "aws_subnet" "dreamkast_dev_private" {
  for_each = toset(data.aws_subnets.dreamkast_dev_private.ids)
  id       = each.value
}

data "aws_subnet" "dreamkast_dev_public" {
  for_each = toset(data.aws_subnets.dreamkast_dev_public.ids)
  id       = each.value
}

# ------------------------------------------------------------#
#  Service Discovery
# ------------------------------------------------------------#
resource "aws_service_discovery_private_dns_namespace" "dreamkast_staging" {
  name = "staging.local"
  vpc  = data.aws_vpc.dreamkast_dev_vpc.id
}

resource "aws_service_discovery_service" "dreamkast_dk" {
  name = "dreamkast"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dreamkast_staging.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "redis" {
  name = "redis"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dreamkast_staging.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

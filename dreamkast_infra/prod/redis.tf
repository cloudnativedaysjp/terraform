module "elasticache-redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.52.0"

  name           = "${var.prj_prefix}-redis"
  description    = "Dreamkast Production Redis"
  instance_type  = var.redis_instance_type
  family         = var.redis_family
  engine_version = var.redis_engine_version

  transit_encryption_enabled = false
  automatic_failover_enabled = true
  multi_az_enabled           = var.multi_az
  cluster_size               = var.redis_num_of_nodes

  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.intra_subnets
  port             = 6379
  allow_all_egress = true
  additional_security_group_rules = [
    {
      type        = "ingress"
      description = "Redis from private subnet"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    },
    {
      type        = "ingress"
      description = "Redis from public subnet"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }
  ]

  replication_group_id     = "${var.prj_prefix}-redis"
  maintenance_window       = "sun:22:00-sun:23:30"
  snapshot_window          = "05:00-09:00"
  snapshot_retention_limit = 7
}

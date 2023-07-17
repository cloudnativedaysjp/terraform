module "elasticache-redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.52.0"

  name             = "${var.prj_prefix}-redis"
  description      = "Dreamkast Production Redis"
  instance_type    = var.redis_instance_type
  engine_version   = var.redis_version

  automatic_failover_enabled = true
  multi_az_enabled           = var.multi_az
  cluster_size               = var.redis_num_of_nodes

  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.intra_subnets
  port                       = 6379
  allowed_security_group_ids = [aws_security_group.allow_redis.id]

  replication_group_id     = "${var.prj_prefix}-redis"
  maintenance_window       = "sun:22:00-sun:23:30"
  snapshot_window          = "05:00-09:00"
  snapshot_retention_limit = 7
}

resource "aws_security_group" "allow_redis" {
  name   = "${var.prj_prefix}-redis-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Redis from private subnet"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
  ingress {
    description = "Redis from public subnet"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.prj_prefix}-redis-sg"
  }
}

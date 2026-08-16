locals {
  redis_instance_type  = "cache.t4g.micro"
  redis_family         = "redis6.x"
  redis_engine_version = "6.0"
  redis_num_of_nodes   = 3
  elasticache_multi_az = false
}

module "elasticache-redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "1.2.2"

  name                 = "${var.prj_prefix}-redis"
  parameter_group_name = "${var.prj_prefix}-redis"
  description          = "Dreamkast Production Redis"
  instance_type        = local.redis_instance_type
  family               = local.redis_family
  engine_version       = local.redis_engine_version

  transit_encryption_enabled = false
  automatic_failover_enabled = true
  multi_az_enabled           = local.elasticache_multi_az
  cluster_size               = local.redis_num_of_nodes

  vpc_id           = aws_vpc.this.id
  subnets          = aws_subnet.intra[*].id
  port             = 6379
  allow_all_egress = true

  # 脱Redis (dreamkast#2844 / v4.20.0) により prod のアプリは Redis を参照しなくなった。
  # ElastiCache には RDS のような stop/start が無いため、削除前の最終確認として
  # ingress を全て外し、クラスタを残したまま到達不能にする。
  #
  # 一定期間問題が無いことを確認できたら、この module ごと削除する。
  # 切り戻す場合はこの commit を revert すれば元の ingress が復活する
  # (private / public サブネットの CIDR から 6379/tcp を許可)。
  additional_security_group_rules = []

  replication_group_id     = "${var.prj_prefix}-redis"
  maintenance_window       = "sun:22:00-sun:23:30"
  snapshot_window          = "05:00-09:00"
  snapshot_retention_limit = 7
}

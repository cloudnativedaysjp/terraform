# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#
variable "prj_prefix" {
  default = "dreamkast-prod"
}

variable "multi_az" {
  default = false
  type    = bool
}

# ------------------------------------------------------------#
#  VPC
# ------------------------------------------------------------#
variable "vpc_cidr" {
  default = "10.110.0.0/16"
}

# ------------------------------------------------------------#
#  EKS
# ------------------------------------------------------------#

variable "cluster_name" {
  default = "dreamkast-prod-cluster"
}
variable "cluster_version" {
  default = 1.27
}

variable "node_group_name" {
  # node_group_name is limited under 38 charactors
  default = "dk-prd-mng-spot"
}

variable "node_desired_size" {
  default = 3
}

variable "node_max_size" {
  default = 5
}

variable "node_min_size" {
  default = 3
}

variable "aws_account_id" {}

# ------------------------------------------------------------#
#  S3
# ------------------------------------------------------------#
variable "s3_bucket_name" {
  default = "bucket"
}

# ------------------------------------------------------------#
#  RDS
# ------------------------------------------------------------#
variable "mysql_major_version" {
  default = "8.0"
}

variable "mysql_minor_version" {
  default = "28"
}

variable "db_instance_name" {
  default = "rds"
}

variable "db_instance_class" {
  default = "db.t3.small"
}

variable "db_instance_storage_size" {
  default = 30
}

variable "db_instance_storage_type" {
  default = "gp3"
}

variable "db_name" {
  default = "dreamkast"
}

variable "db_user_name" {
  default = "admin"
}

variable "long_query_time" {
  default = "1"
}

# ------------------------------------------------------------#
#  ElastiCache Redis
# ------------------------------------------------------------#
variable "redis_instance_type" {
  default = "cache.t4g.small"
}

variable "redis_version" {
  default = "6.0"
}

variable "redis_num_of_nodes" {
  default = 3
}

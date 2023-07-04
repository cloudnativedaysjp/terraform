# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#
variable "prj_prefix" {
  default = "dreamkast-stg"
}

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

variable "multi_az" {
  default = false
  type    = bool
}

variable "long_query_time" {
  default = "1"
}

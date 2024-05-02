# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#
variable "prj_prefix" {
  default = "dreamkast-dev"
}

# ------------------------------------------------------------#
#  EKS
# ------------------------------------------------------------#

variable "cluster_name" {
  default = "dreamkast-dev-cluster"
}
variable "cluster_version" {
  default = 1.28
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

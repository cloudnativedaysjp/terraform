# ------------------------------------------------------------#
#  Common
# ------------------------------------------------------------#
variable "event_name" {
  # used for the path of dreamkast-ui
  default = "cnk"
}

variable "prj_prefix" {
  default = "dreamkast-prod"
}

# ------------------------------------------------------------#
#  EKS
# ------------------------------------------------------------#

variable "cluster_name" {
  default = "dreamkast-prod-cluster"
}
variable "cluster_version" {
  default = 1.28
}

variable "node_group_name" {
  # node_group_name is limited under 38 charactors
  default = "dk-prd-mng-spot"
}

variable "node_desired_size" {
  default = 3
}

variable "node_max_size" {
  default = 10
}

variable "node_min_size" {
  default = 3
}

variable "aws_account_id" {}

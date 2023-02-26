variable "prj_prefix" {
  default = "dk-us-dev"
}

variable "vpc_cidr" {
  default = "10.110.0.0/16"
}

variable "cluster_name" {
  default = "dk-us-dev-cluster"
}
variable "cluster_version" {
  default = 1.24
}

variable "node_desired_size" {
  default = 2
}

variable "node_max_size" {
  default = 5
}

variable "node_min_size" {
  default = 2
}

variable "ecr_name" {
  default = "dk-us-ecs"
}

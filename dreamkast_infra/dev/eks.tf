# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.5.1"

#   cluster_name    = var.cluster_name
#   cluster_version = var.cluster_version

#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.intra_subnets
# }

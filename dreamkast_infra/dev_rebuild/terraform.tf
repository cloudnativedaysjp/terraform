terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "dreamkast_infra_dev_rebuild"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2009
data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.default.token
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "dreamkast_infra_dev"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

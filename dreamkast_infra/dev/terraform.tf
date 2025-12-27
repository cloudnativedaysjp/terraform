terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
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

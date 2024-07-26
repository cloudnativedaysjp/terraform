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
      name = "ecr"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

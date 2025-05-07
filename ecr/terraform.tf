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
  // default provider
  region = "us-west-2"
}

provider "aws" {
  alias  = "ap-northeast-1"
  region = "ap-northeast-1"
}

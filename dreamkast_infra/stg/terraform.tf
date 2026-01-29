terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.30.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "dreamkast_infra_stg"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "ap-northeast-1"
}

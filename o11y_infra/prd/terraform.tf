terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloudnativedaysjp"
    workspaces {
      name = "o11y_infra_prd"
    }
  }
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2.34.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "sakuracloud" {
}
provider "aws" {
}
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloudnativedaysjp"
    workspaces {
      name = "sakuracloud_o11y_stg"
    }
  }
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2.24.0"
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
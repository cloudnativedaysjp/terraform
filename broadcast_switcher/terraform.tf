terraform {
  backend "s3" {
    # Backend configuration is provided via -backend-config flags in GitHub Actions workflow
    bucket  = "dreamkast-terraform-states"
    key     = "broadcast_switcher/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2.24.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

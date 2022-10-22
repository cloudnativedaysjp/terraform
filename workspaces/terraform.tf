terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloudnativedaysjp"

    workspaces {
      name = "workspaces"
    }
  }
  tfe = {
    source  = "hashicorp/tfe"
    version = ">= 0.37.0"
  }
}
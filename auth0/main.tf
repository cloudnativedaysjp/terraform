terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.31.0"
    }
  }
  cloud {
    organization = "cloudnativedaysjp"

    workspaces {
      name = "auth0"
    }
  }
}

provider "auth0" {
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloudnativedaysjp"

    workspaces {
      name = "workspaces"
    }
  }
}
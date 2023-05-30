data "terraform_remote_state" "website" {
  backend = "remote"

  config = {
    organization = "cloudnativedaysjp"
    workspaces = {
      name = "website"
    }
  }
}


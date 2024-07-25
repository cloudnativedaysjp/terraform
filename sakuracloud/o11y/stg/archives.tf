data "sakuracloud_archive" "ubuntu2204" {
  filter {
    id = "113401132828"
  }
}

data "sakuracloud_archive" "ubuntu22042" {
  filter {
    id = "113501244033"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
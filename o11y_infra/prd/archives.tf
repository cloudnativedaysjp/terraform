data "sakuracloud_archive" "ubuntu22042" {
  filter {
    id = "113601946995"
  }
}

data "sakuracloud_archive" "ubuntu2404" {
  filter {
    id = "113601946995"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
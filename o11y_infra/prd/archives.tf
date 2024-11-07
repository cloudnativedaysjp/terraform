data "sakuracloud_archive" "ubuntu22045" {
  filter {
    id = "113601946995"
  }
}

data "sakuracloud_archive" "ubuntu2404" {
  filter {
    id = "113601477512"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
data "sakuracloud_archive" "ubuntu2204" {
  filter {
    id = "113401132828"
  }
}

data "sakuracloud_archive" "ubuntu22042" {
  filter {
    id = "113601946995"
  }
}

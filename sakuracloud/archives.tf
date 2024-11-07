data "sakuracloud_archive" "ubuntu2204" {
  filter {
    id = "113401132828"
  }
}

data "sakuracloud_archive" "ubuntu22045" {
  filter {
    id = "113601946995"
  }
}

data "sakuracloud_archive" "ubuntu" {
  filter {
    id = "113501244030"
  }
}
data "sakuracloud_archive" "ubuntu2204" {
  filter {
    id = "113601946984"
  }
}
data "sakuracloud_archive" "windows" {
  filter {
    id = "113602000481"
  }
}

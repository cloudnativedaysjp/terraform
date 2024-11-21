data "sakuracloud_archive" "ubuntu" {
  filter {
    id = "113600510443"
  }
}
data "sakuracloud_archive" "ubuntu2204" {
  filter {
    id = "113600510445"
  }
}
data "sakuracloud_archive" "windows" {
  filter {
    id = "113602000481"
  }
}

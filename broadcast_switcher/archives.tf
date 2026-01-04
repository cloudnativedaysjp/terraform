data "sakuracloud_archive" "ubuntu" {
  filter {
    tags = ["ubuntu-22.04-latest"]
  }
}
data "sakuracloud_archive" "ubuntu2204" {
  filter {
    tags = ["ubuntu-22.04-latest"]
  }
}
data "sakuracloud_archive" "windows" {
  filter {
    tags = ["distro-ver-2022"]
  }
}

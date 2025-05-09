data "sakuracloud_archive" "ubuntu2204" {
  filter {
    tags = ["@size-extendable","cloud-init","distro-ubuntu","distro-ver-22.04.5","os-linux"]
  }
}

data "sakuracloud_archive" "ubuntu22042" {
  filter {
    tags = ["@size-extendable","cloud-init","distro-ubuntu","distro-ver-22.04.5","os-linux"]
  }
}

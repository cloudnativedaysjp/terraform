resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "sakuracloud_archive" "ubuntu" {
  filter {
    id = "113301413483"
  }
}

resource "sakuracloud_disk" "nextcloud_boot2" {
  name              = "nextcloud-boot2"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 1024

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "nextcloud2" {
  name = "nextcloud2"
  disks = [
    sakuracloud_disk.nextcloud_boot2.id,
  ]
  core        = 4
  memory      = 4
  description = "New Nextcloud server"
  tags        = ["app=nextcloud", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.nextcloud.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/cloud-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "nextcloud2"
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

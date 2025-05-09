resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "sakuracloud_archive" "ubuntu" {
  filter {
    tags = ["@size-extendable","cloud-init","distro-ubuntu","distro-ver-24.04","os-linux"]
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
    hostname    = "nextcloud2",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

# Resources for Unified Nextcloud 3rd Gen
resource "sakuracloud_disk" "nextcloud_boot" {
  name              = "nextcloud-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 2048

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "nextcloud" {
  name = "nextcloud"
  disks = [
    sakuracloud_disk.nextcloud_boot.id,
  ]
  core        = 4
  memory      = 8
  description = "Unified Nextcloud 3rd Gen"
  tags        = ["app=nextcloud", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.nextcloud.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/nextcloud.yaml", {
    vm_password = var.vm_password,
    hostname    = "nextcloud",
    secondary_ip = "192.168.71.111",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}


# Resources for sandbox
resource "sakuracloud_disk" "nc_sandbox_boot" {
  name              = "nc-sandbox-boot"
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

resource "sakuracloud_server" "nc_sandbox" {
  name = "nc-sandbox"
  disks = [
    sakuracloud_disk.nc_sandbox_boot.id,
  ]
  core        = 2
  memory      = 4
  description = "Sandbox for Nextcloud"
  tags        = ["app=nextcloud", "stage=dev"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.nextcloud.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/nextcloud.yaml", {
    vm_password = var.vm_password,
    hostname    = "nc-sandbox",
    secondary_ip = "192.168.71.112",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

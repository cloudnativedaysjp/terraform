resource "sakuracloud_disk" "uploader_boot" {
  name              = "uploader-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "uploader" {
  name = "uploader"
  disks = [
    sakuracloud_disk.uploader_boot.id,
  ]
  core        = 2
  memory      = 4
  description = "Nextcloud Sandbox"
  tags        = ["app=uploader", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.nextcloud.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/cloud-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "uploader",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_disk" "tailscale_boot" {
  name              = "tailscale"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "tailscale" {
  name = "tailscale"
  disks = [
    sakuracloud_disk.tailscale_boot.id,
  ]
  core        = 1
  memory      = 2
  description = "Nextcloud Sandbox"
  tags        = ["app=tailscale", "stage=production", "starred"]

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
    secondary_ip = "192.168.71.249",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

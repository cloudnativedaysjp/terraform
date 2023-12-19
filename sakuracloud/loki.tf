resource "sakuracloud_disk" "loki_boot" {
  name              = "loki"
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

resource "sakuracloud_server" "loki" {
  name = "loki"
  disks = [
    sakuracloud_disk.loki_boot.id,
  ]
  core        = 4
  memory      = 8
  description = "Loki Server"
  tags        = ["app=loki", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.loki.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/cloud-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "loki",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_disk" "loki_boot" {
  name              = "loki"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "loki_docker_volume" {
  name      = "loki-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

resource "sakuracloud_server" "loki" {
  name = "loki"
  disks = [
    sakuracloud_disk.loki_boot.id,
    sakuracloud_disk.loki_docker_volume.id
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

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "loki",
    secondary_ip          = "192.168.0.203",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

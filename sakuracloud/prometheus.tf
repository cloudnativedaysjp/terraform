resource "sakuracloud_disk" "prometheus_boot" {
  name              = "prometheus"
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

resource "sakuracloud_server" "prometheus" {
  name = "prometheus"
  disks = [
    sakuracloud_disk.prometheus_boot.id,
    sakuracloud_disk.prometheus_docker_volume.id,
  ]
  core        = 4
  memory      = 8
  description = "Prometheus Server"
  tags        = ["app=prometheus", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.prometheus.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "prometheus",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_disk" "prometheus_docker_volume" {
  name      = "prometheus-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 100

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}
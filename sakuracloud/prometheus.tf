resource "sakuracloud_disk" "prometheus_boot" {
  name              = "prometheus"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
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

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "prometheus",
    secondary_ip          = "192.168.0.202",
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
}

resource "sakuracloud_disk" "prometheus_boot" {
  name              = "prometheus-stg"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "prometheus_docker_volume" {
  name      = "prometheus-docker-volume-stg"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

resource "sakuracloud_disk" "loki_boot" {
  name              = "loki-stg"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "loki_docker_volume" {
  name      = "loki-docker-volume-stg"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

resource "sakuracloud_disk" "grafana_boot" {
  name              = "grafana-stg"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "grafana_docker_volume" {
  name      = "grafana-docker-volume-stg"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

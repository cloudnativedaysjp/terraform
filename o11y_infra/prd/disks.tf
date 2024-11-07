resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22045.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "sentry_docker_volume" {
  name      = "sentry-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 500
}

resource "sakuracloud_disk" "sentry_redis_boot" {
  name              = "sentry-redis-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22045.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "sentry_redis_docker_volume" {
  name      = "sentry-redis-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 250
}

resource "sakuracloud_disk" "prometheus_boot" {
  name              = "prometheus"
  source_archive_id = data.sakuracloud_archive.ubuntu22045.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "prometheus_docker_volume" {
  name      = "prometheus-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

resource "sakuracloud_disk" "loki_boot" {
  name              = "loki"
  source_archive_id = data.sakuracloud_archive.ubuntu22045.id
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

resource "sakuracloud_disk" "grafana_boot" {
  name              = "grafana"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "grafana_docker_volume" {
  name      = "grafana-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

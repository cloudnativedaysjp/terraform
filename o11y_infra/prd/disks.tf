resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_disk" "sentry_docker_volume" {
  name      = "sentry-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 500
}

resource "sakuracloud_disk" "sentry_redis_boot" {
  name              = "sentry-redis-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_disk" "sentry_redis_docker_volume" {
  name      = "sentry-redis-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 250
}

resource "sakuracloud_disk" "o11y_stacks_boot" {
  name              = "o11y-stacks-prd"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20
}

resource "sakuracloud_disk" "o11y_stacks_docker_volume" {
  name      = "o11y-stacks-docker-volume-prd"
  plan      = "ssd"
  connector = "virtio"
  size      = 250
}

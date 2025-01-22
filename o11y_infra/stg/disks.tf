resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot-stg"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_disk" "sentry_docker_volume" {
  name      = "sentry-docker-volume-stg"
  plan      = "ssd"
  connector = "virtio"
  size      = 250
}

resource "sakuracloud_disk" "o11y_stacks_boot" {
  name              = "o11y-stacks-stg"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20
}

resource "sakuracloud_disk" "o11y_stacks_docker_volume" {
  name      = "o11y-stacks-docker-volume-stg"
  plan      = "ssd"
  connector = "virtio"
  size      = 100
}

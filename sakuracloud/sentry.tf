resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu2204.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "sentry" {
  name = "sentry"
  disks = [
    sakuracloud_disk.sentry_boot.id,
    sakuracloud_disk.sentry_docker_volume.id,
  ]
  core        = 8
  memory      = 32
  description = "Sentry server"
  tags        = ["app=sentry", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "sentry"
    secondary_ip = "192.168.0.200",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
}

resource "sakuracloud_disk" "sentry_docker_volume" {
  name              = "sentry-docker-volume"
  plan              = "ssd"
  connector         = "virtio"
  size              = 500

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_disk" "sentry_redis_boot" {
  name              = "sentry-redis-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu2204.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "sentry_redis" {
  name = "sentry-redis"
  disks = [
    sakuracloud_disk.sentry_redis_boot.id,
    sakuracloud_disk.sentry_redis_docker_volume.id
  ]
  core        = 4
  memory      = 16
  description = "Sentry Redis server"
  tags        = ["app=redis", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "sentry-redis",
    secondary_ip = "192.168.0.201",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
}

resource "sakuracloud_disk" "sentry_redis_docker_volume" {
  name              = "sentry-redis-docker-volume"
  plan              = "ssd"
  connector         = "virtio"
  size              = 250

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

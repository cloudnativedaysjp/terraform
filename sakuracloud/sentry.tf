resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 100
}

resource "sakuracloud_server" "sentry" {
  name = "sentry"
  disks = [
    sakuracloud_disk.sentry_boot.id,
    sakuracloud_disk.sentry_docker_volume.id,
  ]
  core        = 20
  memory      = 32
  description = "Sentry server"
  tags        = ["app=sentry", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry"
    secondary_ip          = "192.168.0.200",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
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
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry_redis.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry-redis",
    secondary_ip          = "192.168.0.201",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
}

resource "sakuracloud_disk" "sentry_redis_docker_volume" {
  name      = "sentry-redis-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 250

}



resource "sakuracloud_disk" "sentry2_boot" {
  name              = "sentry2-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20
}

resource "sakuracloud_disk" "sentry2_docker_volume" {
  name      = "sentry2-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 20
}

resource "sakuracloud_server" "sentry2" {
  name = "sentry2"
  disks = [
    sakuracloud_disk.sentry2_boot.id,
    sakuracloud_disk.sentry2_docker_volume.id,
  ]
  core        = 4
  memory      = 8
  description = "Sentry server"
  tags        = ["app=sentry", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry"
    secondary_ip          = "192.168.0.204",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
}

resource "sakuracloud_disk" "sentry2_redis_boot" {
  name              = "sentry2-redis-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu22042.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20

}

resource "sakuracloud_disk" "sentry2_redis_docker_volume" {
  name      = "sentry2-redis-docker-volume"
  plan      = "ssd"
  connector = "virtio"
  size      = 20

}

resource "sakuracloud_server" "sentry2_redis" {
  name = "sentry2-redis"
  disks = [
    sakuracloud_disk.sentry2_redis_boot.id,
    sakuracloud_disk.sentry2_redis_docker_volume.id
  ]
  core        = 4
  memory      = 16
  description = "Sentry Redis server"
  tags        = ["app=redis", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry_redis.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry-redis",
    secondary_ip          = "192.168.0.205",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })
}

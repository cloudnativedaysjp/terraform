resource "sakuracloud_disk" "sentry_boot" {
  name              = "sentry-boot"
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

resource "sakuracloud_server" "sentry" {
  name = "sentry"
  disks = [
    sakuracloud_disk.sentry_boot.id,
    sakuracloud_disk.sentry_docker_volume.id,
  ]
  core        = 6
  memory      = 16
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
    secondary_ip = "192.168.0.200"
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

resource "sakuracloud_server" "sentry_redis" {
  name = "sentry-redis"
  disks = [
    sakuracloud_disk.sentry_redis_boot.id,
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
    secondary_ip = "192.168.0.201"
  })
}

resource "sakuracloud_disk" "sentry_postgresql_boot" {
  name              = "sentry-postgresql-boot"
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

resource "sakuracloud_server" "sentry_postgresql" {
  name = "sentry-postgresql"
  disks = [
    sakuracloud_disk.sentry_postgresql_boot.id,
    sakuracloud_disk.sentry_postgresql_docker_volume.id
  ]
  core        = 6
  memory      = 16
  description = "Sentry PostgreSQL server"
  tags        = ["app=postgresql", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry_postgres.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "sentry-postgresql",
    secondary_ip = "192.168.0.202"
  })
}

resource "sakuracloud_disk" "sentry_postgresql_docker_volume" {
  name              = "sentry-postgresql-docker-volume"
  plan              = "ssd"
  connector         = "virtio"
  size              = 500

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

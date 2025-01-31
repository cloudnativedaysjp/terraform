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
  })

  lifecycle {
    ignore_changes = [
      user_data,
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
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_server" "o11y_stacks" {
  name = "o11y-stacks-prd"
  disks = [
    sakuracloud_disk.o11y_stacks_boot.id,
    sakuracloud_disk.o11y_stacks_docker_volume.id,
  ]
  core         = 4
  memory       = 8
  description = "Observability stacks for production"
  tags         = ["app=grafana", "app=prometheus", "app=loki", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.o11y_stacks.id
  }

  network_interface {
    upstream = sakuracloud_switch.sentry.id
  }

  user_data = templatefile("./template/o11y-init.yaml", {
    vm_password      = random_password.password.result,
    hostname         = "o11y-stacks-prd",
    secondary_ip     = "192.168.0.202",
    mackerel_api_key = var.mackerel_api_key
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

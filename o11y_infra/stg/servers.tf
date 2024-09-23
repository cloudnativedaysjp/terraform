resource "sakuracloud_server" "sentry" {
  name = "sentry-stg"
  disks = [
    sakuracloud_disk.sentry_boot.id,
    sakuracloud_disk.sentry_docker_volume.id,
  ]
  core        = 6
  memory      = 12
  description = "Sentry server for staging"
  tags        = ["app=sentry", "stage=staging", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry-stg"
    secondary_ip          = "192.168.1.200",
  })
}

resource "sakuracloud_server" "sentry_redis" {
  name = "sentry-redis-stg"
  disks = [
    sakuracloud_disk.sentry_redis_boot.id,
    sakuracloud_disk.sentry_redis_docker_volume.id
  ]
  core        = 2
  memory      = 4
  description = "Sentry Redis server for staging"
  tags        = ["app=redis", "stage=staging", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.sentry_redis.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "sentry-redis-stg",
    secondary_ip          = "192.168.1.201",
  })
}

resource "sakuracloud_server" "prometheus" {
  name = "prometheus-stg"
  disks = [
    sakuracloud_disk.prometheus_boot.id,
    sakuracloud_disk.prometheus_docker_volume.id,
  ]
  core        = 4
  memory      = 8
  description = "Prometheus Server for staging"
  tags        = ["app=prometheus", "stage=staging", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.prometheus.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "prometheus-stg",
    secondary_ip          = "192.168.1.202",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_server" "loki" {
  name = "loki-stg"
  disks = [
    sakuracloud_disk.loki_boot.id,
    sakuracloud_disk.loki_docker_volume.id
  ]
  core        = 2
  memory      = 4
  description = "Loki Server"
  tags        = ["app=loki", "stage=staging", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.loki.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "loki-stg",
    secondary_ip          = "192.168.1.203",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_server" "grafana" {
  name = "grafana-stg"
  disks = [
    sakuracloud_disk.grafana_boot.id,
    sakuracloud_disk.grafana_docker_volume.id
  ]
  core        = 2
  memory      = 4
  description = "Grafana Server"
  tags        = ["app=grafana", "stage=staging", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.grafana.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "grafana-stg",
    secondary_ip          = "192.168.1.204",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

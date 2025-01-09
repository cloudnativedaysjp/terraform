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
    upstream = sakuracloud_switch.o11y.id
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
    upstream = sakuracloud_switch.o11y.id
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
    upstream = sakuracloud_switch.o11y.id
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

resource "sakuracloud_server" "loki" {
  name = "loki"
  disks = [
    sakuracloud_disk.loki_boot.id,
    sakuracloud_disk.loki_docker_volume.id
  ]
  core        = 4
  memory      = 8
  description = "Loki Server"
  tags        = ["app=loki", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.loki.id
  }

  network_interface {
    upstream = sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "loki",
    secondary_ip          = "192.168.0.203",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_server" "grafana" {
  name = "grafana"
  disks = [
    sakuracloud_disk.grafana_boot.id,
    sakuracloud_disk.grafana_docker_volume.id
  ]
  core        = 4
  memory      = 8
  description = "Grafana Server"
  tags        = ["app=grafana", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.grafana.id
  }

  network_interface {
    upstream = sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/sentry-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "grafana",
    secondary_ip          = "192.168.0.204",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

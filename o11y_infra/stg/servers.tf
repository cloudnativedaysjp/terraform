resource "sakuracloud_server" "sentry" {
  name = "sentry-stg"
  disks = [
    sakuracloud_disk.sentry_boot.id,
    sakuracloud_disk.sentry_docker_volume.id,
  ]
  core        = 8
  memory      = 32
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
    vm_password      = random_password.password.result,
    hostname         = "sentry-stg"
    secondary_ip     = "192.168.1.200",
    mackerel_api_key = var.mackerel_api_key
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "sakuracloud_server" "o11y_stacks" {
  name = "o11y-stacks-stg"
  disks = [
    sakuracloud_disk.o11y_stacks_boot.id,
    sakuracloud_disk.o11y_stacks_docker_volume.id,
  ]
  core        = 4
  memory      = 8
  description = "Observability stacks for staging"
  tags        = ["app=grafana", "app=prometheus", "app=loki", "stage=staging", "starred"]

  network_interface {
    upstream = "shared"
    packet_filter_id = sakuracloud_packet_filter.o11y_stacks.id
  }

  network_interface {
    upstream = data.sakuracloud_switch.o11y.id
  }

  user_data = templatefile("./template/o11y-init.yaml", {
    vm_password           = random_password.password.result,
    hostname              = "o11y-stacks-stg",
    secondary_ip          = "192.168.1.202",
    mackerel_api_key      = var.mackerel_api_key
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

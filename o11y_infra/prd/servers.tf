resource "sakuracloud_server" "o11y_stacks" {
  name = "o11y-stacks-prd"
  disks = [
    sakuracloud_disk.o11y_stacks_boot.id,
    sakuracloud_disk.o11y_stacks_docker_volume.id,
  ]
  core        = 4
  memory      = 8
  description = "Observability stacks for production"
  tags        = ["app=grafana", "app=prometheus", "app=loki", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.o11y_stacks.id
  }

  network_interface {
    upstream = sakuracloud_switch.o11y.id
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

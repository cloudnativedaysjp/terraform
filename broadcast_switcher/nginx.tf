locals {
  ## NOTE: Please modify this if you want to add a new instance.
  instances = [
    {
      hostname     = "nginx01",
      secondary_ip = "192.168.71.21"
    },
    {
      hostname     = "nginx02",
      secondary_ip = "192.168.71.22"
    },
    # {
    #   hostname     = "nginx03",
    #   secondary_ip = "192.168.71.23"
    # },
    #  {
    #    hostname     = "nginx04",
    #    secondary_ip = "192.168.71.24"
    #  },
    #  {
    #    hostname     = "nginx05",
    #    secondary_ip = "192.168.71.25"
    #  },
    #  {
    #    hostname     = "nginx06",
    #    secondary_ip = "192.168.71.26"
    #  },
  ]
}

resource "sakuracloud_disk" "instances_boot" {
  for_each          = { for i in local.instances : i.hostname => i }
  name              = "${each.value.hostname}-boot"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "instances" {
  for_each = { for i in local.instances : i.hostname => i }
  name     = each.value.hostname
  disks = [
    sakuracloud_disk.instances_boot[each.key].id
  ]
  core        = 2
  memory      = 4
  description = "Generic insntaces"
  tags        = ["app=instance", "stage=production"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.switcher.id
  }

  network_interface {
    upstream = sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/nginx-cloud-init.yaml", {
    vm_password           = var.vm_password,
    hostname              = each.value.hostname,
    secondary_ip          = each.value.secondary_ip,
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

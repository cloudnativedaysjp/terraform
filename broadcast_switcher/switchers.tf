locals {
  ## NOTE: Please modify this if you want to add a new switcher instance.
  switchers = [
   {
     hostname     = "switcher01",
     secondary_ip = "192.168.71.11"
   },
   {
     hostname     = "switcher02",
     secondary_ip = "192.168.71.12"
   },
   {
     hostname     = "switcher03",
     secondary_ip = "192.168.71.13"
   },
   {
     hostname     = "switcher04",
     secondary_ip = "192.168.71.14"
   },
  #  {
  #    hostname     = "switcher05",
  #    secondary_ip = "192.168.71.15"
  #  },
  #  {
  #    hostname     = "switcher06",
  #    secondary_ip = "192.168.71.16"
  #  },
  ]
}

resource "sakuracloud_disk" "switcher_boot" {
  for_each          = { for i in local.switchers : i.hostname => i }
  name              = "${each.value.hostname}-boot"
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

resource "sakuracloud_disk" "switcher_data" {
  for_each          = { for i in local.switchers : i.hostname => i }
  name              = "${each.value.hostname}-data"
  plan              = "ssd"
  connector         = "virtio"
  size              = 200

  lifecycle {
    ignore_changes = [
      source_archive_id,
    ]
  }
}

resource "sakuracloud_server" "switcher" {
  for_each = { for i in local.switchers : i.hostname => i }
  name     = each.value.hostname
  disks = [
    sakuracloud_disk.switcher_boot[each.key].id,
    sakuracloud_disk.switcher_data[each.key].id
  ]
  core        = 4
  memory      = 56
  gpu         = 1
  description = "Switcher server"
  tags        = ["app=switcher", "stage=production"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.switcher.id
  }

  network_interface {
    upstream = sakuracloud_switch.switcher.id
  }

  user_data = templatefile("./template/switcher-cloud-init.yaml", {
    vm_password  = var.vm_password,
    vnc_password = var.vnc_password,
    hostname     = each.value.hostname,
    secondary_ip = each.value.secondary_ip
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

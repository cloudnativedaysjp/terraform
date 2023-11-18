resource "sakuracloud_disk" "vault_boot" {
  name              = "vault"
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

resource "sakuracloud_server" "vault" {
  name = "vault"
  disks = [
    sakuracloud_disk.vault_boot.id,
  ]
  core        = 2
  memory      = 4
  description = "vault Server"
  tags        = ["app=vault", "stage=production", "starred"]

  network_interface {
    upstream = "shared"
  }

  user_data = templatefile("./template/cloud-init.yaml", {
    vm_password = random_password.password.result,
    hostname    = "vault",
    broadcast_webhook_url = var.broadcast_webhook_url,
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

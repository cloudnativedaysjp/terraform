resource "sakuracloud_disk" "o11y_stacks_boot" {
  name              = "o11y-stacks-prd"
  source_archive_id = data.sakuracloud_archive.ubuntu2404.id
  plan              = "ssd"
  connector         = "virtio"
  size              = 20
}

resource "sakuracloud_disk" "o11y_stacks_docker_volume" {
  name      = "o11y-stacks-docker-volume-prd"
  plan      = "ssd"
  connector = "virtio"
  size      = 250
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cloudnativedaysjp"
    workspaces {
      name = "handson"
    }
  }
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "2.24.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "sakuracloud_archive" "ubuntu" {
  filter {
    name = "ubuntu"
  }
}

data "aws_route53_zone" "cloudnativedays" {
  name         = "cloudnativedays.jp."
  private_zone = false
}

resource "sakuracloud_disk" "handson_dev01_boot" {
  name              = "tailscale"
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

resource "sakuracloud_server" "handson_dev01" {
  name = "handson-dev01"
  disks = [
    sakuracloud_disk.handson_dev01_boot.id,
  ]
  core        = 8
  memory      = 32
  description = "Hands-on Machine 1"
  tags        = ["app=handson", "stage=production", "starred"]

  network_interface {
    upstream         = "shared"
    packet_filter_id = sakuracloud_packet_filter.handson.id
  }

  user_data = templatefile("./template/handson-cloud-init.yaml", {
    vm_password = var.vm_password,
    hostname    = "handson-dev01",
  })

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}

resource "aws_route53_record" "handson_dev01" {
  zone_id  = data.aws_route53_zone.cloudnativedays.zone_id
  name     = "handson-dev01.cloudnativedays.jp"
  type     = "A"
  ttl      = "300"
  records  = [sakuracloud_server.handson_dev01.ip_address]
}

resource "sakuracloud_packet_filter" "handson" {
  name        = "handson"
  description = "Packet filtering rules for handson VMs"
}

resource "sakuracloud_packet_filter_rules" "handson_rules" {
  packet_filter_id = sakuracloud_packet_filter.handson.id

  expression {
    protocol         = "tcp"
    destination_port = "22"
  }

  expression {
    protocol         = "tcp"
    destination_port = "80"
  }

  expression {
    protocol         = "tcp"
    destination_port = "443"
  }

  expression {
    protocol         = "tcp"
    destination_port = "8080"
  }

  expression {
    protocol         = "tcp"
    destination_port = "8443"
  }

  expression {
    protocol         = "tcp"
    destination_port = "18080"
  }

  expression {
    protocol         = "tcp"
    destination_port = "18443"
  }

  expression {
    protocol         = "tcp"
    destination_port = "28080"
  }

  expression {
    protocol         = "tcp"
    destination_port = "28443"
  }

  expression {
    protocol         = "udp"
    destination_port = "68"
  }

  expression {
    protocol = "icmp"
  }

  expression {
    protocol = "fragment"
  }

  expression {
    protocol    = "udp"
    source_port = "123"
  }

  expression {
    protocol         = "tcp"
    destination_port = "32768-61000"
  }

  expression {
    protocol         = "udp"
    destination_port = "32768-61000"
  }
  expression {
    protocol    = "ip"
    allow       = false
    description = "Deny ALL"
  }
}

resource "sakuracloud_internet" "global" {
  name = "global"

  netmask     = 28
  band_width  = 250
  enable_ipv6 = false

  description = "global"
  tags        = ["global", "production"]
}

resource "sakuracloud_switch" "switcher" {
  name        = "handson-switcher"
  description = "switcher"
  tags        = ["handson", "production"]
}

module "vm1" {
  source  = "app.terraform.io/cloudnativedaysjp/handson/sacloud"
  version = "0.0.5"
  machine_id                 = "handson-2"
  vm_password                = "A!waysbek1nd"
  additional_github_accounts = ["jacopen"]
  sakuracloud_zone           = "is1b"
  cpu_core = 8
  memory_size = 32
}

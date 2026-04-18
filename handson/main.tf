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
      version = "2.34.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "sakuracloud_archive" "ubuntu" {
  filter {
    tags = ["@size-extendable","cloud-init","distro-ubuntu","distro-ver-24.04.2","os-linux"]
  }
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

resource "sakuracloud_switch" "switcher" {
  name        = "handson-switcher"
  description = "switcher"
  tags        = ["handson", "production"]
}

module "vm1" {
  source  = "app.terraform.io/cloudnativedaysjp/handson/sacloud"
  version = "0.0.7"
  machine_id                 = "handson-2"
  vm_password                = "A!waysbek1nd"
  additional_github_accounts = ["jacopen"]
  sakuracloud_zone           = "is1b"
  cpu_core = 8
  memory_size = 32
  archive_id = data.sakuracloud_archive.ubuntu.id
}

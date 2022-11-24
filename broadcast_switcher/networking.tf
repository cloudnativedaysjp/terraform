resource "sakuracloud_switch" "switcher" {
  name        = "switcher"
  description = "switcher"
  tags        = ["switcher", "production"]
}
resource "sakuracloud_internet" "global" {
  name = "global"

  netmask     = 28
  band_width  = 250
  enable_ipv6 = false

  description = "global"
  tags        = ["global", "production"]
}


resource "sakuracloud_packet_filter" "switcher" {
  name        = "switcher"
  description = "Packet filtering rules for switcher VM"
}

locals {
  global_ips = [
    {
      name = "sakura",
      ip   = "61.211.224.11"
    },
    {
      name = "jacopen",
      ip   = "124.36.216.208"
    },
    {
      name = "ijokarumawak",
      ip   = "114.146.66.9"
    },
    {
      name = "kameneko",
      ip   = "123.198.149.243"
    },
    {
      name = "capsmalt",
      ip   = "153.246.198.141"
    },
    {
      name = "room3",
      ip   = "114.159.226.190"
    },
    {
      name = "room3_wired",
      ip   = "58.88.211.157"
    },
    {
      name = "gaku_Izu-Oshima",
      ip   = "210.139.3.185"
    },
  ]
}

resource "sakuracloud_packet_filter_rules" "switcher_rules" {
  packet_filter_id = sakuracloud_packet_filter.switcher.id

  dynamic "expression" {
    for_each = { for i in local.global_ips : i.name => i }
    content {
      protocol         = "tcp"
      destination_port = "22"
      source_network   = expression.value.ip
    }
  }

  dynamic "expression" {
    for_each = { for i in local.global_ips : i.name => i }
    content {
      protocol         = "tcp"
      destination_port = "5900"
      source_network   = expression.value.ip
    }
  }

  expression {
    protocol         = "tcp"
    destination_port = "80"
  }

  expression {
    protocol         = "tcp"
    destination_port = "8080"
  }

  expression {
    protocol         = "tcp"
    destination_port = "443"
  }

  expression {
    protocol         = "udp"
    destination_port = "10000-11000"
  }

  expression {
    protocol         = "tcp"
    destination_port = "10000-11000"
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

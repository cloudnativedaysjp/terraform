data "sakuracloud_switch" "o11y" {
  filter {
    names = ["o11y"]
  }
}

resource "sakuracloud_packet_filter" "o11y_stacks" {
  name        = "o11y-stacks-stg"
  description = "Packet filtering rules for staging o11y stacks VM"
}

resource "sakuracloud_packet_filter_rules" "o11y_stacks_rules" {
  packet_filter_id = sakuracloud_packet_filter.o11y_stacks.id

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

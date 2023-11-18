resource "sakuracloud_packet_filter" "nextcloud" {
  name        = "nextcloud"
  description = "Packet filtering rules for nextcloud VM"
}

resource "sakuracloud_packet_filter" "sentry_postgres" {
  name        = "sentry-postgres"
  description = "Packet filtering rules for Sentry PostgreSQL VM"
}

data "sakuracloud_switch" "switcher" {
  filter {
    names = ["switcher"]
  }
}

resource "sakuracloud_switch" "sentry" {
  name        = "sentry"
  description = "sentry"
  tags        = ["sentry"]
}

resource "sakuracloud_packet_filter_rules" "nextcloud_rules" {
  packet_filter_id = sakuracloud_packet_filter.nextcloud.id

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
    protocol         = "tcp"
    destination_port = "8200"
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

resource "sakuracloud_packet_filter_rules" "sentry_postgres_rules" {
  packet_filter_id = sakuracloud_packet_filter.sentry_postgres.id

  expression {
    protocol         = "tcp"
    destination_port = "22"
  }

  expression {
    protocol = "icmp"
  }

  expression {
    protocol    = "ip"
    allow       = false
    description = "Deny ALL"
  }
}

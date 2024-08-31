resource "sakuracloud_switch" "sentry" {
  name        = "sentry"
  description = "sentry"
  tags        = ["sentry"]
}

resource "sakuracloud_packet_filter" "sentry" {
  name        = "sentry"
  description = "Packet filtering rules for Sentry VM"
}

resource "sakuracloud_packet_filter" "sentry_redis" {
  name        = "sentry-redis"
  description = "Packet filtering rules for Sentry Redis VM"
}

resource "sakuracloud_packet_filter" "prometheus" {
  name        = "prometheus"
  description = "Packet filtering rules for prometheus VM"
}

resource "sakuracloud_packet_filter" "loki" {
  name        = "loki"
  description = "Packet filtering rules for loki VM"
}

resource "sakuracloud_packet_filter" "grafana" {
  name        = "grafana"
  description = "Packet filtering rules for grafana VM"
}

resource "sakuracloud_packet_filter_rules" "sentry_rules" {
  packet_filter_id = sakuracloud_packet_filter.sentry.id

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

resource "sakuracloud_packet_filter_rules" "sentry_redis_rules" {
  packet_filter_id = sakuracloud_packet_filter.sentry_redis.id

  expression {
    protocol         = "tcp"
    destination_port = "22"
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

resource "sakuracloud_packet_filter_rules" "prometheus_rules" {
  packet_filter_id = sakuracloud_packet_filter.prometheus.id

  expression {
    protocol         = "tcp"
    destination_port = "22"
  }

  expression {
    protocol         = "tcp"
    destination_port = "9090"
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

resource "sakuracloud_packet_filter_rules" "loki_rules" {
  packet_filter_id = sakuracloud_packet_filter.loki.id

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

resource "sakuracloud_packet_filter_rules" "grafana_rules" {
  packet_filter_id = sakuracloud_packet_filter.grafana.id

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
    destination_port = "3000"
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

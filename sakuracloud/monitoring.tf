resource "sakuracloud_simple_monitor" "uploader" {
  target = "uploader.cloudnativedays.jp"

  delay_loop = 60
  timeout    = 10

  max_check_attempts = 3
  retry_interval     = 10

  health_check {
    protocol        = "https"
    port            = 443
    path            = "/"
    status          = "302"
    host_header     = "uploader.cloudnativedays.jp"
    sni             = false
    http2           = false
  }

  description = "Monitoring for NextCloud"

  notify_interval = 2
  notify_email_enabled = false
  notify_slack_enabled = true
  notify_slack_webhook = var.slack_webhook_url
}

resource "sakuracloud_simple_monitor" "dreamkast" {
  target = "event.cloudnativedays.jp"

  delay_loop = 60
  timeout    = 10

  max_check_attempts = 3
  retry_interval     = 10

  health_check {
    protocol        = "https"
    port            = 443
    path            = "/"
    status          = "200"
    host_header     = "event.cloudnativedays.jp"
    sni             = true
    http2           = false
  }

  description = "Monitoring for Dreamkast"

  notify_interval = 2
  notify_email_enabled = false
  notify_slack_enabled = true
  notify_slack_webhook = var.slack_webhook_url
}

resource "sakuracloud_simple_monitor" "website" {
  target = "cloudnativedays.jp"

  delay_loop = 60
  timeout    = 10

  max_check_attempts = 3
  retry_interval     = 10

  health_check {
    protocol        = "https"
    port            = 443
    path            = "/"
    status          = "200"
    host_header     = "cloudnativedays.jp"
    sni             = true
    http2           = false
  }

  description = "Monitoring for Website"

  notify_interval = 2
  notify_email_enabled = false
  notify_slack_enabled = true
  notify_slack_webhook = var.slack_webhook_url
}

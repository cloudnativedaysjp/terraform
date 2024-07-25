resource "sakuracloud_simple_monitor" "prometheus" {
  target = "stg.prometheus.cloudnativedays.jp"

  delay_loop = 120
  timeout    = 20

  max_check_attempts = 5
  retry_interval     = 20

  health_check {
    protocol        = "https"
    port            = 443
    path            = "/-/healthy"
    status          = "401" # prometheusのpassword忘れた・・・
    host_header     = "stg.prometheus.cloudnativedays.jp"
    sni             = true
    http2           = true
    # username        = "prometheus"
    # password        = var.prometheus_password
  }

  description = "Monitoring for staging Prometheus"

  notify_interval = 2
  notify_email_enabled = false
  notify_slack_enabled = true
  notify_slack_webhook = var.slack_webhook_url
}
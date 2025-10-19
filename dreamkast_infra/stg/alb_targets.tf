data "aws_lb_listener" "alb" {
  arn = "arn:aws:elasticloadbalancing:us-west-2:607167088920:listener/app/dreamkast-dev/122c5b4a47b64f9d/bc86e7b2e4bca8f5"
}

# ------------------------------------------------------------#
# for dreamkast
# ------------------------------------------------------------#
resource "aws_lb_listener_rule" "dreamkast_dk" {
  listener_arn = data.aws_lb_listener.alb.arn
  priority     = 9
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_dk.arn
  }
  condition {
    host_header {
      values = ["staging.dev.cloudnativedays.jp"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
resource "aws_lb_target_group" "dreamkast_dk" {
  name        = "dreamkast-staging-dk"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.dreamkast_dev_vpc.id
  target_type = "ip"

  deregistration_delay = 60

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# ------------------------------------------------------------#
# for dreamkast-ui
# ------------------------------------------------------------#
resource "aws_lb_listener_rule" "dreamkast_ui" {
  listener_arn = data.aws_lb_listener.alb.arn
  priority     = 3
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_ui.arn
  }
  condition {
    host_header {
      values = ["staging.dev.cloudnativedays.jp"]
    }
  }
  condition {
    path_pattern {
      values = [
        "/${var.event_name}/ui/*",
        "/${var.event_name}/ui",
        "/_next/*"
      ]
    }
  }
}
resource "aws_lb_target_group" "dreamkast_ui" {
  name        = "dreamkast-staging-ui"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.dreamkast_dev_vpc.id
  target_type = "ip"

  deregistration_delay = 60

  health_check {
    protocol            = "HTTP"
    path                = "/${var.event_name}/ui"
    port                = 3001
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# ------------------------------------------------------------#
# for dreamkast-weaver
# ------------------------------------------------------------#
resource "aws_lb_listener_rule" "dreamkast_weaver" {
  listener_arn = data.aws_lb_listener.alb.arn
  priority     = 6
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_weaver.arn
  }
  condition {
    host_header {
      values = ["dkw.dev.cloudnativedays.jp"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
resource "aws_lb_target_group" "dreamkast_weaver" {
  name        = "dreamkast-staging-weaver"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.dreamkast_dev_vpc.id
  target_type = "ip"

  deregistration_delay = 60

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = 8080
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

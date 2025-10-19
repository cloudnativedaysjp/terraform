# ------------------------------------------------------------#
# for dreamkast
# ------------------------------------------------------------#
resource "aws_lb_listener_rule" "dreamkast_dk" {
  listener_arn = aws_lb_listener.alb.arn
  priority     = 9
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_dk.arn
  }
  condition {
    host_header {
      values = ["event.cloudnativedays.jp"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
resource "aws_lb_target_group" "dreamkast_dk" {
  name        = "dreamkast-production-dk"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
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
  listener_arn = aws_lb_listener.alb.arn
  priority     = 3
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_ui.arn
  }
  condition {
    host_header {
      values = ["event.cloudnativedays.jp"]
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
  name        = "dreamkast-production-ui"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  deregistration_delay = 60

  health_check {
    protocol            = "HTTP"
    path                = "/${var.event_name}/ui"
    port                = 3001
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

# ------------------------------------------------------------#
# for dreamkast-weaver
# ------------------------------------------------------------#
resource "aws_lb_listener_rule" "dreamkast_weaver" {
  listener_arn = aws_lb_listener.alb.arn
  priority     = 6
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dreamkast_weaver.arn
  }
  condition {
    host_header {
      values = ["dkw.cloudnativedays.jp"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
resource "aws_lb_target_group" "dreamkast_weaver" {
  name        = "dreamkast-production-weaver"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
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

resource "aws_lb" "alb" {
  name               = var.prj_prefix
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id

  security_groups = [
    aws_security_group.alb.id
  ]

  enable_deletion_protection = true

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_security_group" "alb" {
  name   = "${var.prj_prefix}-alb"
  vpc_id = aws_vpc.this.id

  ingress {
    description = "allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all"
    protocol    = "all"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.wildcard_cloudnativedays_jp.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
      message_body = "no appropriately backends"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.wildcard_cloudnativedays_jp
  ]

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}

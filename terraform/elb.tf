resource "aws_alb" "default" {
  name                       = "${var.app_name}-${terraform.workspace}"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = true
  subnets                    = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id,
    aws_subnet.public_d.id
  ]

  security_groups = [
    module.loadblancer_sg.this_security_group_id
  ]

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_lb_target_group" "rails" {
  name                 = "${var.app_name}-${terraform.workspace}-rails"
  vpc_id               = aws_vpc.default.id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 30

  health_check {
    path                = var.rails_health_check_path
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "1800"
  }

  depends_on = [aws_alb.default]
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_alb.default.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "redirect"
    redirect {
      host        = var.domain_name[terraform.workspace]
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "redirect" {
  listener_arn = aws_lb_listener.default.arn
  priority     = 98

  action {
    type = "redirect"
    redirect {
      host        = var.domain_name[terraform.workspace]
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["www.${var.domain_name[terraform.workspace]}"]
    }
  }
}

resource "aws_lb_listener_rule" "rails" {
  listener_arn = aws_lb_listener.default.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rails.arn
  }

  condition {
    http_header {
      http_header_name = "User-Agent"
      values           = ["Amazon CloudFront"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-Pre-Shared-Key"
      values           = [random_string.alb_authorization.result]
    }
  }
}

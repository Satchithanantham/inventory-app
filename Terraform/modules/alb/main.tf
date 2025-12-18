
################################
# ALB SECURITY GROUP
################################
resource "aws_security_group" "alb" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = var.vpc_id

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (conditional)
  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Egress anywhere (you can tighten to VPC CIDRs if needed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.app_name}-alb-sg" })
}

################################
# APPLICATION LOAD BALANCER
################################
resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  idle_timeout               = 60
  enable_deletion_protection = false

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix != null ? var.access_logs_prefix : "alb"
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = "${var.app_name}-alb" })
  depends_on = [
    aws_s3_bucket.alb_logs,
    aws_s3_bucket_ownership_controls.alb_logs,
    aws_s3_bucket_policy.alb_logs
  ]
}

################################
# TARGET GROUP - BACKEND (API)
# For Fargate IP targets: keep TG port 80; ECS registers per-target port (5000)
################################
resource "aws_lb_target_group" "api" {
  name        = "${var.app_name}-api-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.api_health_check_path # default: "/health"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.app_name}-api-tg" })
}

################################
# TARGET GROUP - FRONTEND
################################
resource "aws_lb_target_group" "frontend" {
  name        = "${var.app_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    port                = "traffic-port"
    path                = var.frontend_health_check_path # default: "/"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, { Name = "${var.app_name}-frontend-tg" })
}

################################
# HTTP LISTENER (80)
################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  # If HTTPS enabled, redirect all HTTP traffic to HTTPS
  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # If HTTPS disabled, forward to frontend by default
  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.frontend.arn
    }
  }

  depends_on = [
    aws_lb_target_group.api,
    aws_lb_target_group.frontend
  ]
}

################################
# HTTPS LISTENER (443) - OPTIONAL
################################
resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  depends_on = [aws_lb_target_group.api, aws_lb_target_group.frontend]
}

################################
# LISTENER RULE: /api/* → BACKEND (HTTP)
# Disabled when HTTPS enabled (we redirect HTTP to HTTPS)
################################
resource "aws_lb_listener_rule" "api_http" {
  count        = var.enable_https ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern { values = ["/api/*"] }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  depends_on = [aws_lb_target_group.api]
}

################################
# LISTENER RULE: /api/* → BACKEND (HTTPS)
################################
resource "aws_lb_listener_rule" "api_https" {
  count        = var.enable_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  condition {
    path_pattern { values = ["/api/*"] }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

################################
# LISTENER RULE: / → FRONTEND (HTTP)
# Optional: when HTTPS disabled, default_action already forwards to frontend.
# Keeping this rule is harmless, but can be disabled to reduce redundancy.
################################
resource "aws_lb_listener_rule" "frontend_http" {
  count        = var.enable_https ? 0 : 1
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  condition {
    path_pattern { values = ["/"] }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  depends_on = [aws_lb_target_group.frontend]
}

################################
# LISTENER RULE: / → FRONTEND (HTTPS)
################################
resource "aws_lb_listener_rule" "frontend_https" {
  count        = var.enable_https ? 1 : 0
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  condition {
    path_pattern { values = ["/"] }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

}

data "aws_caller_identity" "current" {}


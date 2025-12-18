output "alb_arn" {
  value = aws_lb.load_balancer.arn
}

output "alb_dns_name" {
  value = aws_lb.load_balancer.dns_name
}

output "alb_zone_id" {
  value = aws_lb.load_balancer.zone_id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "api_tg_arn" {
  value = aws_lb_target_group.api.arn
}

output "frontend_tg_arn" {
  value = aws_lb_target_group.frontend.arn
}
output "alb_arn_suffix" {
  description = "ALB ARN suffix (used for CloudWatch metric dimensions)"
  value = replace(
    aws_lb.load_balancer.arn,
    "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:loadbalancer/",
    ""
  )
}

output "api_tg_arn_suffix" {
  description = "API target group ARN suffix (for CloudWatch alarms)"
  value = replace(
    aws_lb_target_group.api.arn,
    "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:targetgroup/",
    ""
  )
}

output "frontend_tg_arn_suffix" {
  description = "Frontend target group ARN suffix (for CloudWatch alarms)"
  value = replace(
    aws_lb_target_group.frontend.arn,
    "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:targetgroup/",
    ""
  )
}

output "api_tg_dns_name" {
  description = "DNS name for the API target group (if separate ALB or listener)"
  value       = aws_lb.load_balancer.dns_name
}

output "frontend_tg_dns_name" {
  description = "DNS name for the frontend target group (if separate ALB or listener)"
  value       = aws_lb.load_balancer.dns_name
}

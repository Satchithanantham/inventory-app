# ECS Cluster
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "Name of the ECS cluster"
}

# Backend ECS Service
output "ecs_backend_service_name" {
  value       = module.ecs_backend.service_name
  description = "Backend ECS service name"
}

# Frontend ECS Service
output "ecs_frontend_service_name" {
  value       = module.ecs_frontend.service_name
  description = "Frontend ECS service name"
}

# ALB Outputs
output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ALB ARN"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS Name"
}

output "alb_zone_id" {
  value       = module.alb.alb_zone_id
  description = "ALB Hosted Zone ID"
}

output "alb_sg_id" {
  value       = module.alb.alb_sg_id
  description = "ALB Security Group ID"
}

output "api_tg_arn" {
  value       = module.alb.api_tg_arn
  description = "Target group ARN for backend ECS"
}

output "frontend_tg_arn" {
  value       = module.alb.frontend_tg_arn
  description = "Target group ARN for frontend ECS"
}

output "alb_arn_suffix" {
  value       = module.alb.alb_arn_suffix
  description = "ALB ARN suffix for CloudWatch alarms"
}

# SNS
output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS Topic ARN for alarms"
}

output "aws_cloudwatch_log_group_api" {
  value       = module.cloudwatch_api.log_group_name
  description = "CloudWatch log group name for backend"
}
output "aws_cloudwatch_log_group_frontend" {
  value       = module.cloudwatch_frontend.log_group_name
  description = "CloudWatch log group name for frontend"
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

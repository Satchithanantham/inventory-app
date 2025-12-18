output "ecs_cpu_alarm_names" {
  description = "ECS CPU high alarm names"
  value = [
    for alarm in aws_cloudwatch_metric_alarm.ecs_cpu_high :
    alarm.alarm_name
  ]
}

output "ecs_memory_alarm_names" {
  description = "ECS memory high alarm names"
  value = [
    for alarm in aws_cloudwatch_metric_alarm.ecs_memory_high :
    alarm.alarm_name
  ]
}

output "alb_5xx_alarm_names" {
  description = "ALB 5XX alarm names"
  value = [
    for alarm in aws_cloudwatch_metric_alarm.alb_5xx :
    alarm.alarm_name
  ]
}

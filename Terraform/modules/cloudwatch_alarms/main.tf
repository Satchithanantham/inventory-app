# ----------------------------
# ECS CPU Alarms
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = length(var.ecs_services)
  alarm_name          = "${var.app_name}-${var.ecs_services[count.index].name}-cpu-high"
  alarm_description   = "ECS CPU utilization high"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.ecs_services[count.index].cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_services[count.index].cluster_name
    ServiceName = var.ecs_services[count.index].service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

# ----------------------------
# ECS Memory Alarms
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count               = length(var.ecs_services)
  alarm_name          = "${var.app_name}-${var.ecs_services[count.index].name}-memory-high"
  alarm_description   = "ECS Memory utilization high"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.ecs_services[count.index].memory_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_services[count.index].cluster_name
    ServiceName = var.ecs_services[count.index].service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

# ----------------------------
# ALB 5XX Alarms
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count               = length(var.albs)
  alarm_name          = "${var.app_name}-${var.albs[count.index].name}-5xx"
  alarm_description   = "ALB 5XX errors high"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.albs[count.index].threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TargetGroup  = var.albs[count.index].arn_suffix
    LoadBalancer = var.albs[count.index].arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

resource "aws_cloudwatch_log_group" "cloudwatch_lg" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}

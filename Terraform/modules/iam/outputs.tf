
output "task_exec_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.task_exec.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task application role"
  value       = aws_iam_role.task_role.arn
}

output "task_exec_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.task_exec.name
}

output "task_role_name" {
  description = "Name of the ECS task application role"
  value       = aws_iam_role.task_role.name
}

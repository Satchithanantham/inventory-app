
output "db_address" {
  description = "RDS endpoint address"
  value       = aws_db_instance.db_instance.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.db_instance.port
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

output "db_username" {
  description = "RDS username from Secrets Manager"
  value       = local.db_username
}

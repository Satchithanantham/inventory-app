output "db_password_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}

output "db_password_id" {
  value = aws_secretsmanager_secret.db_password.id
}

output "db_username_arn" {
  value = aws_secretsmanager_secret.db_username.arn
}
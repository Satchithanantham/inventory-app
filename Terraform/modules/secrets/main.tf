resource "aws_secretsmanager_secret" "db_username" {
  name        = "${var.app_name}-db-username"
  description = "DB username for ${var.app_name}"
}

resource "aws_secretsmanager_secret_version" "db_username" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.app_name}-db-password"
  description = "DB password for ${var.app_name}"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# Read DB password from Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_arn
}

locals {
  db_secret   = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)
  db_username = local.db_secret.username
  db_password = local.db_secret.password
}

# RDS Security Group (only ECS allowed)
resource "aws_security_group" "rds" {
  name   = "${var.app_name}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.engine == "postgres" ? 5432 : 3306
    to_port         = var.engine == "postgres" ? 5432 : 3306
    protocol        = "tcp"
    security_groups = [var.ecs_sg_id]
    description     = "ECS to RDS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# RDS instance
resource "aws_db_instance" "db_instance" {
  identifier        = "${var.app_name}-db"
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = local.db_username
  password = local.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name

  monitoring_interval = 0
  publicly_accessible = false
  skip_final_snapshot = true
}


locals {
  db_env = length(trim(var.db_host, " ")) > 0 ? [
    { name = "DB_HOST", value = var.db_host },
    { name = "DB_PORT", value = var.db_port },
    { name = "DB_NAME", value = var.db_name }
  ] : []

   db_secrets = length(trim(var.db_password_secret_arn, "")) > 0 ? [
    { name = "DB_USER",     valueFrom = "${var.db_password_secret_arn}:username::" },
    { name = "DB_PASSWORD", valueFrom = "${var.db_password_secret_arn}:password::" }
  ] : []
}
resource "aws_ecs_service" "api" {
  name            = var.app_name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
    assign_public_ip = false
 
 }
 load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
 depends_on = [aws_ecs_task_definition.api, var.target_group_arn]
}


resource "aws_ecs_task_definition" "api" {
  family                   = var.app_name
  execution_role_arn       = var.task_exec_role_arn
  task_role_arn            = var.task_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = local.db_env
      secrets     = local.db_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = var.app_name
        }
      }
    }
  ])
}

# ----------------------------
# 0) ECR repo for backend
# ----------------------------
module "ecr" {
  source           = "./modules/ecr"
  app_name         = var.app_name
  ecr_repositories = var.ecr_repositories
  scan_on_push     = true
  immutable_tags   = false

  lifecycle_policy_json = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 50 images"
      selection = {
        tagStatus = "any"
        countType = "imageCountMoreThan"
        count     = 50
      }
      action = { type = "expire" }
    }]
  })
}

# ----------------------------
# 1) IAM roles for ECS
# ----------------------------
module "iam" {
  source   = "./modules/iam"
  app_name = var.app_name

  allowed_secret_arns   = ["*"]
  kms_key_arns          = []
  enable_ssm_param_read = false
}

# ----------------------------
# 2) CloudWatch Log Group
# ----------------------------
module "cloudwatch_api" {
  source            = "./modules/cloudwatch"
  app_name          = var.app_name
  log_group_name    = "/ecs/${var.app_name}-api"
  retention_in_days = 14
}

module "cloudwatch_frontend" {
  source            = "./modules/cloudwatch"
  app_name          = var.app_name
  log_group_name    = "/ecs/${var.app_name}-frontend"
  retention_in_days = 14
}

# S3 Bucket for ALB Access Logs (already defined in your S3 module)
module "s3" {
  source   = "./modules/s3_logs"
  app_name = var.app_name
  env      = var.env
}
# ----------------------------
# 3) ALB
# ----------------------------
module "alb" {
  source            = "./modules/alb"
  app_name          = var.app_name
  aws_region        = var.aws_region
  vpc_id            = var.vpc_id
  public_subnet_ids = var.public_subnet_ids

  enable_https    = var.enable_https
  certificate_arn = var.certificate_arn

  enable_access_logs = true
  access_logs_bucket = module.s3.alb_logs_bucket_name
  access_logs_prefix = "alb"

  depends_on = [aws_ecs_cluster.main]
}


# ----------------------------
# ECS Cluster
# ----------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

# ECS SG: only ALB can reach container port
resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS tasks SG"

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [module.alb.alb_sg_id]
    description     = "ALB to Backend API"
  }


  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.alb_sg_id]
    description     = "ALB to Frontend"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [
    module.alb
  ]

}


# ----------------------------
# 4) ECS Services
# ----------------------------
module "ecs_backend" {
  source = "./modules/ecs"

  app_name       = "${var.app_name}-api"
  container_name = "backend"
  ecs_cluster_id = aws_ecs_cluster.main.id
  aws_region     = var.aws_region

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  ecs_sg_id          = aws_security_group.ecs.id
  target_group_arn   = module.alb.api_tg_arn

  image          = "${module.ecr.repository_urls["backend"]}:${var.image_tag}"
  container_port = 5000
  cpu            = var.cpu
  memory         = var.memory
  desired_count  = var.desired_count

  log_group_name     = module.cloudwatch_api.log_group_name
  task_exec_role_arn = module.iam.task_exec_role_arn
  task_role_arn      = module.iam.task_role_arn

  # Required for backend
  db_host                = module.rds.db_address
  db_port                = tostring(module.rds.db_port)
  db_name                = var.db_name
  db_username_secret_arn = var.db_username_secret_arn
  db_password_secret_arn = var.db_password_secret_arn

  depends_on = [
    aws_ecs_cluster.main,
    module.alb,
    module.cloudwatch_api,
    module.iam,
    module.rds
  ]
}

module "ecs_frontend" {
  source = "./modules/ecs"

  app_name       = "${var.app_name}-frontend"
  container_name = "frontend"
  ecs_cluster_id = aws_ecs_cluster.main.id
  aws_region     = var.aws_region

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  ecs_sg_id          = aws_security_group.ecs.id
  target_group_arn   = module.alb.frontend_tg_arn

  image          = "${module.ecr.repository_urls["frontend"]}:${var.image_tag}"
  container_port = 80
  cpu            = 256
  memory         = 512
  desired_count  = 1

  log_group_name     = module.cloudwatch_frontend.log_group_name
  task_exec_role_arn = module.iam.task_exec_role_arn
  task_role_arn      = module.iam.task_role_arn

  secrets = []

  depends_on = [
    aws_ecs_cluster.main,
    module.alb,
    module.cloudwatch_frontend,
    module.iam
  ]
}


# ----------------------------
# 5) RDS
# ----------------------------
module "rds" {
  source   = "./modules/rds"
  app_name = var.app_name
  vpc_id   = var.vpc_id

  private_subnet_ids     = var.private_subnet_ids
  ecs_sg_id              = aws_security_group.ecs.id
  engine                 = "mysql"
  engine_version         = "8.0"
  db_name                = "inventory"
  db_password_secret_arn = var.db_password_secret_arn
  depends_on             = [aws_security_group.ecs]
}

# ----------------------------
# 6) Optional Route53
# ----------------------------
module "dns" {
  source         = "./modules/dns"
  hosted_zone_id = "Z0498892K4FC3M48S0VV"
  alb_zone_id    = module.alb.alb_zone_id

  records = {
    api      = module.alb.alb_dns_name
    frontend = module.alb.alb_dns_name
  }
}

# ----------------------------
# 7) WAF
# ----------------------------
module "waf" {
  source         = "./modules/waf"
  web_acl_name   = "${var.app_name}-waf"
  scope          = "REGIONAL"
  alb_arn        = module.alb.alb_arn
  enable_logging = false
  firehose_arn   = null
}

# ----------------------------
# 8) SNS for alarms
# ----------------------------
resource "aws_sns_topic" "alerts" {
  name = "${var.app_name}-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ----------------------------
# 9) Unified ECS + ALB alarms
# ----------------------------
module "alarms" {
  source = "./modules/cloudwatch_alarms"

  app_name      = var.app_name
  sns_topic_arn = aws_sns_topic.alerts.arn

  ecs_services = [
    {
      name             = "backend"
      cluster_name     = aws_ecs_cluster.main.name
      service_name     = module.ecs_backend.service_name
      cpu_threshold    = 80
      memory_threshold = 80
    },
    {
      name             = "frontend"
      cluster_name     = aws_ecs_cluster.main.name
      service_name     = module.ecs_frontend.service_name
      cpu_threshold    = 80
      memory_threshold = 80
    }
  ]

  albs = [
    {
      name           = "api-alb"
      arn_suffix     = module.alb.api_tg_arn_suffix
      alb_arn_suffix = module.alb.alb_arn_suffix
      threshold      = 5
    },
    {
      name           = "frontend-alb"
      alb_arn_suffix = module.alb.alb_arn_suffix
      arn_suffix     = module.alb.frontend_tg_arn_suffix
      threshold      = 5
    }
  ]
  depends_on = [module.ecs_backend, module.ecs_frontend, module.alb]
}

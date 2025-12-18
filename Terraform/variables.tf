variable "aws_region" {
  type = string
}

variable "account_id" {
  type        = string
}


variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

# ALB / HTTPS
variable "enable_https" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type    = string
  default = null

  validation {
    condition     = var.enable_https == false || var.certificate_arn != null
    error_message = "certificate_arn must be set when enable_https is true."
  }
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

# ECR Repositories
variable "ecr_repositories" {
  type = list(string)
}

# ECS container
variable "container_port" {
  type    = number
  default = 5000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

# ECR tag to deploy
variable "image_tag" {
  type = string
}

# Env vars & Secrets for container
variable "environment" {
  type    = map(string)
  default = {}
}

# Optional DNS
variable "hosted_zone_id" {
  type    = string
  default = null
}

variable "ecs_sg_id" {
  type        = string
  default = " "
}

variable "db_password_secret_arn" {
  type = string
  default = ""
}

variable "db_name" {
  type        = string
  default     = "inventory"
}

variable "alert_email" {
  type        = string
  description = "Email to receive alarm notifications"
}

variable "api_domain_name" {
  type    = string
  default = null
}

variable "db_username_secret_arn" {
  type        = string
  default = ""
}

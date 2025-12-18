variable "app_name" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "ecs_sg_id" {
  type    = string
  default = " "
}
variable "target_group_arn" {
  type = string
}

variable "image" {
  type = string
}

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

variable "log_group_name" {
  type = string
}

variable "task_exec_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}
variable "ecs_cluster_id" {
  type = string
}
variable "container_name" {
  type = string
}

variable "db_host" {
  type    = string
  default = ""
}

variable "db_port" {
  type    = string
  default = ""
}

variable "db_name" {
  type    = string
  default = ""
}

variable "db_username_secret_arn" {
  type    = string
  default = ""
}

variable "db_password_secret_arn" {
  type    = string
  default = ""
}

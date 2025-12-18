variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "engine" {
  type    = string
  default = "mysql" # mysql | postgres
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type = string
}

variable "db_password_secret_arn" {
  type    = string
  default = ""
}

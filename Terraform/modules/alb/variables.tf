variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "target_port" {
  type    = number
  default = 80
}

variable "api_health_check_path" {
  type    = string
  default = "/health"
}
variable "frontend_health_check_path" {
  type    = string
  default = "/"
}

variable "enable_https" {
  type    = bool
  default = false
}

variable "certificate_arn" {
  type    = string
  default = null
}

variable "enable_access_logs" {
  type    = bool
  default = false
}

variable "access_logs_bucket" {
  type    = string
  default = null
}

variable "access_logs_prefix" {
  type    = string
  default = null
}
variable "ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-2016-08"
  }

variable "tags" {
  type    = map(string)
  default = {}
}



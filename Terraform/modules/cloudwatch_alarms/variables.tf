variable "app_name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "ecs_services" {
  type = list(object({
    name             = string
    cluster_name     = string
    service_name     = string
    cpu_threshold    = number
    memory_threshold = number
  }))
  default = [
    {
      name           = "backend"
      cluster_name   = "inventory-cluster"
      service_name   = "backend-service"
      cpu_threshold  = 80
      memory_threshold = 80
    },
    {
      name           = "frontend"
      cluster_name   = "inventory-cluster"
      service_name   = "frontend-service"
      cpu_threshold  = 80
      memory_threshold = 80
    }
  ]
}

variable "albs" {
  type = list(object({
    name       = string
    arn_suffix = string
    threshold  = number
  }))
  default = [
    {
      name       = "app-alb"
      arn_suffix = "alb-1234"
      threshold  = 5
    }
  ]
}

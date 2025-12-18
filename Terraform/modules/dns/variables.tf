variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "alb_zone_id" {
  type        = string
  description = "ALB hosted zone ID"
}

variable "records" {
  type        = map(string)
  default = {}
  description = "Map of subdomain names to ALB DNS names, e.g. { api = <dns>, frontend = <dns> }"
}

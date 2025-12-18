variable "app_name" {
  type = string
}

variable "ecr_repositories" {
  type    = list(string)
  default = ["frontend", "backend"]
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "immutable_tags" {
  type    = bool
  default = false
}

variable "lifecycle_policy_json" {
  type    = string
  default = null
}

variable "app_name" {
        type   = string
}

# Scope the task role to only these Secrets Manager ARNs (least privilege).
variable "allowed_secret_arns" {
  type        = list(string)
  default     = []
}

# If your secrets/parameters use customer-managed KMS keys, add their ARNs here.
variable "kms_key_arns" {
  description = "KMS key ARNs for decrypt permissions"
  type        = list(string)
  default     = []
}

# Grant task role read access to SSM Parameter Store (optional)
variable "enable_ssm_param_read" {
  description = "Enable SSM Parameter Store read permissions on task role"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags for IAM resources"
  type        = map(string)
  default     = {}
}

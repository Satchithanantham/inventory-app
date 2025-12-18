variable "web_acl_name" {
  description = "Name of the WAF Web ACL"
  type        = string
}

variable "scope" {
  description = "Scope of WAF (REGIONAL for ALB, CLOUDFRONT for CF)"
  type        = string
  default     = "REGIONAL"
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
}

variable "enable_logging" {
  description = "Enable WAF logging to Kinesis Firehose"
  type        = bool
  default     = false
}

variable "firehose_arn" {
  description = "Kinesis Firehose ARN for WAF logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for WAF resources"
  type        = map(string)
  default     = {}
}

output "alb_access_logs_bucket_name" {
  description = "S3 bucket name where ALB access logs are stored"
  value       = aws_s3_bucket.alb_logs.bucket
}

output "alb_access_logs_bucket_arn" {
  description = "ARN of the S3 bucket storing ALB access logs"
  value       = aws_s3_bucket.alb_logs.arn
}
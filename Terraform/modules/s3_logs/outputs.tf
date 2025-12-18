output "alb_logs_bucket_name" {
  description = "S3 bucket name where ALB access logs are stored"
  value       = aws_s3_bucket.alb_logs.bucket
}

output "alb_logs_bucket_arn" {
  description = "ARN of the S3 bucket storing ALB access logs"
  value       = aws_s3_bucket.alb_logs.arn
}

output "alb_bucket_id" {
  value = aws_s3_bucket.alb_logs.id
}

output "alb_bucket_ownership_controls" {
  value = aws_s3_bucket_ownership_controls.alb_logs.id
}

output "alb_bucket_policy" {
  value = aws_s3_bucket_policy.alb_logs.id
}
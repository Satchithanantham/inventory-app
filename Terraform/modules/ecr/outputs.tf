output "repository_urls" {
  description = "Map of repository URLs"
  value       = { for k, repo in aws_ecr_repository.repos : k => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository ARNs"
  value       = { for k, repo in aws_ecr_repository.repos : k => repo.arn }
}

output "repository_names" {
  description = "Map of repository names"
  value       = { for k, repo in aws_ecr_repository.repos : k => repo.name }
}

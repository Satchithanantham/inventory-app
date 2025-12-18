# Create ECR repositories dynamically
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.ecr_repositories)

  name = "${var.app_name}-${each.value}"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  image_tag_mutability = var.immutable_tags ? "IMMUTABLE" : "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Optional lifecycle policy for each repository
resource "aws_ecr_lifecycle_policy" "repos_lc" {
  for_each = var.lifecycle_policy_json != null ? aws_ecr_repository.repos : {}

  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


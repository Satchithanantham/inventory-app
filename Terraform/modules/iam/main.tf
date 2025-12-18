
############################
# ECS TASK EXECUTION ROLE  #
############################

resource "aws_iam_role" "task_exec" {
  name = "${var.app_name}-task-exec"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# AWS-managed baseline: ECR pull & CloudWatch logs
resource "aws_iam_role_policy_attachment" "task_exec_attach" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Extra permissions: Secrets Manager (and optional KMS decrypt) for container secrets resolution
data "aws_iam_policy_document" "task_exec_extra" {
  statement {
    sid       = "SecretsReadForContainerLaunch"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"] # scope to specific ARNs if desired
  }

  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [true] : []
    content {
      sid       = "KMSDecryptForSecrets"
      actions   = ["kms:Decrypt"]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_policy" "task_exec_extra" {
  name   = "${var.app_name}-task-exec-extra"
  policy = data.aws_iam_policy_document.task_exec_extra.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "task_exec_extra_attach" {
  role       = aws_iam_role.task_exec.name
  policy_arn = aws_iam_policy.task_exec_extra.arn
}

#####################
# ECS TASK ROLE     #
#####################

resource "aws_iam_role" "task_role" {
  name = "${var.app_name}-task-role"
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Least-privilege app permissions
data "aws_iam_policy_document" "task_role_base" {
  # Secrets Manager scoped read
  statement {
    sid     = "SecretsReadScoped"
    actions = ["secretsmanager:GetSecretValue"]
    resources = length(var.allowed_secret_arns) > 0 ? var.allowed_secret_arns : ["*"]
  }

  # Optional SSM Parameter Store read
  dynamic "statement" {
    for_each = var.enable_ssm_param_read ? [true] : []
    content {
      sid     = "SSMParameterRead"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = ["*"]
    }
  }

  # Optional KMS decrypt for runtime (if CMK is used)
  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [true] : []
    content {
      sid       = "KMSDecryptForRuntime"
      actions   = ["kms:Decrypt"]
      resources = var.kms_key_arns
    }
  }
}

resource "aws_iam_policy" "task_role_base" {
  name   = "${var.app_name}-task-role-base"
  policy = data.aws_iam_policy_document.task_role_base.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "task_role_attach" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_role_base.arn
}


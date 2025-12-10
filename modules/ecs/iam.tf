data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  count = var.enable_execute_command ? 1 : 0
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}



data "aws_iam_policy_document" "ecs_task_execution_policy" {
  # count = var.docker_hub_secrets_arn != null || var.db_secret_arn != null ? 1 : 0
  count = length(var.secrets_allowed_arns) > 0 ? 1 : 0
  statement {
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret"
    ]
    resources = compact(var.secrets_allowed_arns)
    effect    = "Allow"
  }
}

## ECS EXECUTION ROLE allows pulling images from ecr and logging
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.deployment_name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  count = length(var.secrets_allowed_arns) > 0 ? 1 : 0

  name        = "${var.deployment_name}-ecs-execution-policy-secrets"
  description = "Allow read of secrets from secrets manager"
  policy      = data.aws_iam_policy_document.ecs_task_execution_policy[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_get_secret" {
  count = length(var.secrets_allowed_arns) > 0 ? 1 : 0

  policy_arn = aws_iam_policy.ecs_task_execution_policy[0].arn
  role       = aws_iam_role.ecs_execution_role.name
}



## ECS TASK ROLE allows ecs exec if enabled
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.deployment_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}


resource "aws_iam_policy" "ecs_task_policy" {
  count       = var.enable_execute_command ? 1 : 0
  name        = "${var.deployment_name}-ecs_task_policy"
  description = "Allow exec into your containers"
  policy      = data.aws_iam_policy_document.ecs_task_policy[0].json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  count      = var.enable_execute_command ? 1 : 0
  policy_arn = aws_iam_policy.ecs_task_policy[0].arn
  role       = aws_iam_role.ecs_task_role.name
}


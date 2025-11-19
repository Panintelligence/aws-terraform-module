data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement  {
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["ecs-tasks.amazonaws.com"]
      }
      effect = "Allow"
    }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement  {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
    effect = "Allow"
  }
}


data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement  {
    actions = [
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:GetSecretValue",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.docker_hub_secrets_arn]
    effect = "Allow"
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
  name        = "${var.deployment_name}-ecs-execution-policy-secrets"
  description = "Allow read of docker secret in secrets manager"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

#TODO: make this optional if secret needed
resource "aws_iam_role_policy_attachment" "ecs_execution_role_get_secret" {
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}

## ECS TASK ROLE allows ecs exec if enabled

#TODO: make this a variable

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.deployment_name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}


resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.deployment_name}-ecs_task_policy"
  description = "Allow exec into your containers"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}


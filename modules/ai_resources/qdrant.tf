data "aws_region" "current" {}
data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


locals {
  env_variables = [for k, v in var.task_env_vars : { name = k, value = v }]
}

resource "aws_ecs_task_definition" "qdrant" {
  family = "${var.deployment_name}-qdrant"
  container_definitions = jsonencode([{
    name      = "qdrant"
    essential = true
    image     = var.docker_image
    memory    = var.qdrant_memory
    cpu       = var.qdrant_cpu

    repositoryCredentials = var.docker_hub_secrets_arn != null ? { credentialsParameter = var.docker_hub_secrets_arn } : null

    portMappings = [
      {
      containerPort = 6333
      hostPort      = 6333
      protocol      = "tcp"
      name          = "qdrant-http"
      },
      {
      containerPort = 6334
      hostPort      = 6334
      protocol      = "tcp"
      name          = "qdrant-grpc"
      }
    ]

    environment = local.env_variables

    LogConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/aws/ecs/${var.deployment_name}-qdrant"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory             = var.qdrant_memory
  cpu                = var.qdrant_cpu
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
}

resource "aws_cloudwatch_log_group" "qdrant" {
  name = "/aws/ecs/${var.deployment_name}-qdrant"
}


resource "aws_ecs_service" "qdrant" {
  name                   = "qdrant"
  cluster                = var.aws_ecs_cluster_id
  task_definition        = aws_ecs_task_definition.qdrant.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.application_subnet_ids
    security_groups  = concat([aws_security_group.qdrant.id], var.qdrant_sec_group_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.qdrant.arn
    container_name   = "qdrant"
    container_port   = 6333
  }
}

resource "aws_lb_target_group" "qdrant" {
  name        = "${var.deployment_name}-qdrant"
  port        = 6333
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 15
    path                = "/"
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener_rule" "qdrant" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.qdrant.arn
  }

  condition {
    host_header {
      values = [var.qdrant_private_domain]
    }
  }
}


resource "aws_security_group" "qdrant" {
  name        = "${var.deployment_name}-qdrant"
  description = "Main ${var.deployment_name} qdrant security group"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
}


resource "aws_vpc_security_group_ingress_rule" "qdrant_alb" {
  security_group_id            = aws_security_group.qdrant.id
  description                  = "Allow traffic from private ALB"
  ip_protocol                  = "tcp"
  from_port                    = 6333
  to_port                      = 6333
  referenced_security_group_id = var.alb_sg_id
}

resource "aws_vpc_security_group_egress_rule" "qdrant_egress" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.qdrant.id
}


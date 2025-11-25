data "aws_region" "current" {}
data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


locals {
  env_variables = [for k, v in var.task_env_vars : { name = k, value = v }]
}

resource "aws_ecs_task_definition" "pirana" {
  family = "${var.deployment_name}-pirana"
  container_definitions = jsonencode([{
    name      = "pirana"
    essential = true
    image     = var.docker_image
    memory    = var.pirana_memory
    cpu       = var.pirana_cpu

    repositoryCredentials = var.docker_hub_secrets_arn != null ? { credentialsParameter = var.docker_hub_secrets_arn } : null

    portMappings = [{
      containerPort = 9918
      hostPort      = 9918
      appProtocol   = "http",
      protocol      = "tcp"
      name          = "pirana"
    }]

    environment = local.env_variables

    LogConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/aws/ecs/${var.deployment_name}-pirana"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  network_mode = "awsvpc"
  requires_compatibilities = [
  "FARGATE"]
  memory             = var.pirana_memory
  cpu                = var.pirana_cpu
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
}

resource "aws_cloudwatch_log_group" "pirana" {
  name = "/aws/ecs/${var.deployment_name}-pirana"
}


resource "aws_ecs_service" "pirana" {
  name                   = "pirana"
  cluster                = var.aws_ecs_cluster_id
  task_definition        = aws_ecs_task_definition.pirana.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = var.enable_execute_command

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.application_subnet_ids
    security_groups  = concat([aws_security_group.pirana.id], var.pirana_sec_group_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.pirana.arn
    container_name   = "pirana"
    container_port   = 9918
  }
}

resource "aws_lb_target_group" "pirana" {
  name        = "${var.deployment_name}-pirana"
  port        = 9918
  protocol    = "HTTP"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 15
    path                = "/version"
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener_rule" "pirana" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pirana.arn
  }

  condition {
    host_header {
      values = [var.pirana_private_domain]
    }
  }
}

resource "aws_security_group" "pirana" {
  name        = "${var.deployment_name}-pirana"
  description = "Main ${var.deployment_name} pirana security group"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.pirana.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "pirana_alb" {
  security_group_id            = aws_security_group.pirana.id
  description                  = "Allow traffic from private ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9918
  to_port                      = 9918
  referenced_security_group_id = var.private_alb_sg_id
}
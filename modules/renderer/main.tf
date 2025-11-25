data "aws_region" "current" {}
data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


locals {
  env_variables = [for k, v in var.task_env_vars : { name = k, value = v }]
}

resource "aws_ecs_task_definition" "renderer" {
  family = "${var.deployment_name}-renderer"
  container_definitions = jsonencode([{
    name      = "renderer"
    essential = true
    image     = var.docker_image
    memory    = var.renderer_memory
    cpu       = var.renderer_cpu

    repositoryCredentials = var.docker_hub_secrets_arn != null ? { credentialsParameter = var.docker_hub_secrets_arn } : null

    portMappings = [{
      containerPort = 9915
      hostPort      = 9915
      appProtocol   = "http",
      protocol      = "tcp"
      name          = "renderer"
    }]

    environment = local.env_variables

    LogConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/aws/ecs/${var.deployment_name}-renderer"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
  "FARGATE"]
  memory = var.renderer_memory
  cpu    = var.renderer_cpu
}

resource "aws_cloudwatch_log_group" "renderer" {
  name = "/aws/ecs/${var.deployment_name}-renderer"
}


resource "aws_ecs_service" "renderer" {
  name                   = "renderer"
  cluster                = var.aws_ecs_cluster_id
  task_definition        = aws_ecs_task_definition.renderer.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = var.enable_execute_command

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.application_subnet_ids
    security_groups  = concat([aws_security_group.renderer.id], var.renderer_sec_group_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.renderer.arn
    container_name   = "renderer"
    container_port   = 9915
  }
}


resource "aws_lb_target_group" "renderer" {
  name        = "${var.deployment_name}-renderer"
  port        = 9915
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


resource "aws_lb_listener_rule" "renderer" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.renderer.arn
  }

  condition {
    host_header {
      values = [var.renderer_private_domain]
    }
  }
}

resource "aws_security_group" "renderer" {
  name        = "${var.deployment_name}-renderer"
  description = "Main ${var.deployment_name} renderer security group"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.renderer.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


resource "aws_vpc_security_group_ingress_rule" "renderer_private_alb" {
  security_group_id            = aws_security_group.renderer.id
  description                  = "Allow traffic from private ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9915
  to_port                      = 9915
  referenced_security_group_id = var.private_alb_sg_id
}
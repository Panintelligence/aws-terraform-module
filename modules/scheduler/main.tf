data "aws_region" "current" {}

data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


locals {
  env_variables      = [for k, v in var.task_env_vars : { name = k, value = v }]
  database_variables = [for k, v in var.database_env_vars : { name = k, value = v }]
}


resource "aws_ecs_task_definition" "scheduler" {
  family = "${var.deployment_name}-scheduler"
  container_definitions = jsonencode([{
    name      = "scheduler"
    essential = true
    image     = var.docker_image
    memory    = var.scheduler_memory
    cpu       = var.scheduler_cpu

    repositoryCredentials = var.docker_hub_secrets_arn != null ? { credentialsParameter = var.docker_hub_secrets_arn } : null

    portMappings = [{
      containerPort = 9917
      hostPort      = 9917
      appProtocol   = "http",
      protocol      = "tcp"
      name          = "scheduler"
    }]

    environment = concat(local.env_variables, local.database_variables)

    mountPoints = [{
      containerPath = "/var/panintelligence/Dashboard/keys",
      sourceVolume  = "keys"
    }]

    LogConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/aws/ecs/${var.deployment_name}-scheduler"
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  volume {
    name = "keys"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/keys"
    }
  }

  network_mode = "awsvpc"
  requires_compatibilities = [
  "FARGATE"]
  memory             = var.scheduler_memory
  cpu                = var.scheduler_cpu
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn
}

resource "aws_cloudwatch_log_group" "scheduler" {
  name = "/aws/ecs/${var.deployment_name}-scheduler"
}

resource "aws_ecs_service" "scheduler" {
  name                   = "scheduler"
  cluster                = var.aws_ecs_cluster_id
  task_definition        = aws_ecs_task_definition.scheduler.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = var.enable_execute_command

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = var.application_subnet_ids
    security_groups  = concat([aws_security_group.scheduler.id], var.scheduler_sec_groups_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.scheduler.arn
    container_name   = "scheduler"
    container_port   = 9917
  }
}


resource "aws_lb_target_group" "scheduler" {
  name        = "${var.deployment_name}-scheduler"
  port        = 9917
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


resource "aws_lb_listener_rule" "scheduler" {
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.scheduler.arn
  }

  condition {
    host_header {
      values = [var.scheduler_private_domain]
    }
  }
}

resource "aws_security_group" "scheduler" {
  name        = "${var.deployment_name}-scheduler"
  description = "Main ${var.deployment_name} scheduler security group"
  vpc_id      = data.aws_subnet.private_subnet.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.scheduler.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  security_group_id            = var.efs_security_group_id
  description                  = "Allow traffic from ${var.deployment_name} scheduler to EFS"
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  referenced_security_group_id = aws_security_group.scheduler.id

}


resource "aws_vpc_security_group_ingress_rule" "scheduler_private_alb" {
  security_group_id            = aws_security_group.scheduler.id
  description                  = "Allow traffic from private ALB"
  ip_protocol                  = "tcp"
  from_port                    = 9917
  to_port                      = 9917
  referenced_security_group_id = var.private_alb_sg_id
}
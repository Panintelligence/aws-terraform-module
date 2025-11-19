data "aws_region" "current" {}
data "aws_subnet" "private_subnet" {
  id = var.application_subnet_ids[0]
}


locals {
  env_variables = [for k, v in var.task_env_vars : { name = k, value = v }]
  database_variables = [for k, v in var.database_env_vars : { name = k, value = v }]
}

resource "aws_ecs_task_definition" "dashboard" {
  family = "${var.deployment_name}-dashboard"
  container_definitions = jsonencode([{
    name = "dashboard"
    essential = true
    memory = var.dashboard_memory
    cpu = var.dashboard_cpu
    image = var.docker_image

    repositoryCredentials = {
      credentialsParameter = var.docker_hub_secrets_arn
    }

    portMappings = [
      {
        containerPort = 8224,
        hostPort = 8224,
        appProtocol = "http",
        protocol = "tcp"
        name = "dashboard"
      },
      {
        containerPort = 28748,
        hostPort = 28748,
        appProtocol = "http",
        protocol = "tcp"
        name = "dashboard-internal"
      }
    ]

    environment = concat(local.env_variables, local.database_variables)

    mountPoints = [
      {
        sourceVolume = "themes",
        containerPath = "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/themes"
      },
      {
        sourceVolume = "images",
        containerPath = "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/images"
      },
      {
        sourceVolume = "files",
        containerPath = "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/files"
      },
      {
        sourceVolume = "keys",
        containerPath = "/var/panintelligence/Dashboard/keys"
      },
      {
        sourceVolume = "svg",
        containerPath = "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/svg"
      },
      {
        sourceVolume = "custom_jdbc",
        containerPath = "/var/panintelligence/Dashboard/custom_jdbc"
      },
      {
        sourceVolume = "locale",
        containerPath = "/var/panintelligence/Dashboard/tomcat/webapps/panMISDashboardResources/locale"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group = "/aws/ecs/${var.deployment_name}-dashboard"
        awslogs-region = data.aws_region.current.name
        awslogs-stream-prefix = "ecs"
      }
    }

  }])

  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"]
  memory = var.dashboard_memory
  cpu = var.dashboard_cpu
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn

  volume {
    name = "themes"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/themes"
    }
  }

  volume {
    name = "locale"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/locale"
    }
  }

  volume {
    name = "keys"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/keys"
    }
  }

  volume {
    name = "images"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/images"
    }
  }

  volume {
    name = "files"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/files"
    }
  }

  volume {
    name = "svg"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/svg"
    }
  }

  volume {
    name = "custom_jdbc"
    efs_volume_configuration {
      file_system_id = var.dashboard_efs_id
      root_directory = "/custom_jdbc"
    }
  }
}

resource "aws_cloudwatch_log_group" "dashboard" {
  name = "/aws/ecs/${var.deployment_name}-dashboard"
  retention_in_days = 14
}


resource "aws_ecs_service" "dashboard" {
  name = "dashboard"
  cluster = var.aws_ecs_cluster_id
  task_definition = aws_ecs_task_definition.dashboard.arn
  desired_count = 1
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  health_check_grace_period_seconds = 80

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = var.application_subnet_ids
    security_groups = concat([aws_security_group.dashboard.id], var.dashboard_sec_groups_ids)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dashboard.arn
    container_name = "dashboard"
    container_port = 8224
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.dashboard_internal.arn
    container_name = "dashboard"
    container_port = 28748
  }
}

resource "aws_lb_target_group" "dashboard" {
  name = "${var.deployment_name}-dashboard"
  port = 8224
  protocol = "HTTP"
  vpc_id = data.aws_subnet.private_subnet.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 15
    path = "/pi/version"
    timeout = 5
    matcher = "200"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "dashboard_internal" {
  name = "${var.deployment_name}-dashboard-int"
  port = 28748
  protocol = "HTTP"
  vpc_id = data.aws_subnet.private_subnet.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 15
    path = "/pi/version"
    timeout = 5
    matcher = "200"
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}



resource "aws_lb_listener_rule" "dashboard" {
  listener_arn = var.alb_listener_external_arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }

  condition {
    host_header {
      values = [var.dashboard_public_domain]
    }
  }
}


resource "aws_lb_listener_rule" "dashboard_internal" {
  listener_arn = var.alb_listener_internal_arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.dashboard_internal.arn
  }

  condition {
    host_header {
      values = [var.dashboard_private_domain]
    }
  }
}

resource "aws_security_group" "dashboard" {
  name = "${var.deployment_name}-dashboard"
  description = "Main ${var.deployment_name} dashboard security group"
  vpc_id = data.aws_subnet.private_subnet.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.dashboard.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  security_group_id = var.efs_security_group_id
  description = "Allow traffic from ${var.deployment_name} dashboard to EFS"
  ip_protocol       = "tcp"
  from_port         = 2049
  to_port           = 2049
  referenced_security_group_id = aws_security_group.dashboard.id

}


resource "aws_vpc_security_group_ingress_rule" "dashboard_public_alb" {
  security_group_id = aws_security_group.dashboard.id
  description       = "Allow traffic from public ALB"
  ip_protocol       = "tcp"
  from_port         = 8224
  to_port           = 8224
  referenced_security_group_id = var.public_alb_sg_id
}


resource "aws_vpc_security_group_ingress_rule" "dashboard_private_alb" {
  security_group_id = aws_security_group.dashboard.id
  description       = "Allow traffic from private ALB"
  ip_protocol       = "tcp"
  from_port         = 28748
  to_port           = 28748
  referenced_security_group_id = var.private_alb_sg_id
}

resource "aws_ecs_cluster" "pi" {
  name = var.deployment_name
  setting {
    name = "containerInsights"
    value = var.container_insights_setting
  }

  tags = {
    Name = var.deployment_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "pi" {
  cluster_name = aws_ecs_cluster.pi.name
  #TODO: options for ec2
  capacity_providers = ["FARGATE"]
}
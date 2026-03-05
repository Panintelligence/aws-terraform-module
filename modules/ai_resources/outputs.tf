output "task_definition" {
  value = aws_ecs_task_definition.qdrant
}

output "service" {
  value = aws_ecs_service.qdrant
}

output "target_group" {
  value = aws_lb_target_group.qdrant
}

output "listener_rule" {
  value = aws_lb_listener_rule.qdrant
}

output "main_security_group" {
  value = aws_security_group.qdrant
}
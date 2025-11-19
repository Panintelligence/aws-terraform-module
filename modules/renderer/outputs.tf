output "task_definition" {
  value = aws_ecs_task_definition.renderer
}

output "service" {
  value = aws_ecs_service.renderer
}

output "target_group" {
  value = aws_lb_target_group.renderer
}

output "listener_rule" {
  value = aws_lb_listener_rule.renderer
}

output "main_security_group" {
  value = aws_security_group.renderer
}
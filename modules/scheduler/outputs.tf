output "task_definition" {
  value = aws_ecs_task_definition.scheduler
}

output "service" {
  value = aws_ecs_service.scheduler
}

output "target_group" {
  value = aws_lb_target_group.scheduler
}

output "listener_rule" {
  value = aws_lb_listener_rule.scheduler
}

output "main_security_group" {
  value = aws_security_group.scheduler
}
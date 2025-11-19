output "task_definition" {
  value = aws_ecs_task_definition.pirana
}

output "service" {
  value = aws_ecs_service.pirana
}

output "target_group" {
  value = aws_lb_target_group.pirana
}

output "listener_rule" {
  value = aws_lb_listener_rule.pirana
}

output "main_security_group" {
  value = aws_security_group.pirana
}
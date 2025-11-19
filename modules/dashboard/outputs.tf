output "internal_target_group" {
  value = aws_lb_target_group.dashboard_internal
}

output "external_target_group" {
  value = aws_lb_target_group.dashboard
}

output "task_definition" {
  value = aws_ecs_task_definition.dashboard
}

output "service" {
  value = aws_ecs_service.dashboard
}

output "external_listener_rule" {
  value = aws_lb_listener_rule.dashboard
}

output "internal_listener_rule" {
  value = aws_lb_listener_rule.dashboard_internal
}


output "main_security_group" {
  value = aws_security_group.dashboard
}
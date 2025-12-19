output "task_definition" {
  value = try(aws_ecs_task_definition.scheduler[0], null)
}

output "service" {
  value = try(aws_ecs_service.scheduler[0], null)
}

output "target_group" {
  value = try(aws_lb_target_group.scheduler[0], null)
}

output "listener_rule" {
  value = try(aws_lb_listener_rule.scheduler[0], null)
}

output "main_security_group" {
  value = aws_security_group.scheduler
}
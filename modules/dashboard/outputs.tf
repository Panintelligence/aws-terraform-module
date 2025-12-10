output "internal_target_group" {
  value =try(aws_lb_target_group.dashboard["external"], null)
}

output "external_target_group" {
  value = try(aws_lb_target_group.dashboard["internal"], null)
}

output "task_definition" {
  value = aws_ecs_task_definition.dashboard
}

output "service" {
  value = aws_ecs_service.dashboard
}

output "external_listener_rule" {
  value = try(aws_lb_listener_rule.dashboard["external"], null)
}

output "internal_listener_rule" {
  value = try(aws_lb_listener_rule.dashboard["internal"], null)
}


output "main_security_group" {
  value = aws_security_group.dashboard
}
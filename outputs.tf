output "ecs_cluster" {
  value = module.ecs.ecs_cluster
}

output "ecs_task_role" {
  value = module.ecs.ecs_task_role
}

output "ecs_execution_role" {
  value = module.ecs.ecs_task_execution_role
}




output "efs_file_system" {
  value = module.efs.efs_file_system
}

output "efs_security_group" {
  value = module.efs.efs_security_group
}

output "efs_lambda" {
  value = try(module.lambda[0].lambda_function, null)
}

output "efs_lambda_role" {
  value = try(module.lambda[0].lambda_role, null)
}

output "efs_lambda_security_group" {
  value = try(module.lambda[0].lambda_security_group, null)
}




output "dashboard_internal_target_group" {
  value = try(module.dashboard[0].internal_target_group, null)
}

output "dashboard_external_target_group" {
  value = try(module.dashboard[0].external_listener_rule, null)
}

output "dashboard_task_definition" {
  value = try(module.dashboard[0].task_definition, null)
}

output "dashboard_service" {
  value = try(module.dashboard[0].service, null)
}

output "dashboard_external_listener_rule" {
  value = try(module.dashboard[0].external_listener_rule, null)
}

output "dashboard_internal_listener_rule" {
  value = try(module.dashboard[0].internal_listener_rule, null)
}

output "dashboard_security_group" {
  value = try(module.dashboard[0].main_security_group, null)
}




output "renderer_target_group" {
  value = try(module.renderer[0].listener_rule, null)
}

output "renderer_task_definition" {
  value = try(module.renderer[0].task_definition, null)
}

output "renderer_service" {
  value = try(module.renderer[0].service, null)
}

output "renderer_listener_rule" {
  value = try(module.renderer[0].listener_rule, null)
}

output "renderer_security_group" {
  value = try(module.renderer[0].main_security_group, null)
}




output "scheduler_target_group" {
  value = try(module.scheduler[0].listener_rule, null)
}

output "scheduler_task_definition" {
  value = try(module.scheduler[0].task_definition, null)
}

output "scheduler_service" {
  value = try(module.scheduler[0].service, null)
}

output "scheduler_listener_rule" {
  value = try(module.scheduler[0].listener_rule, null)
}

output "scheduler_security_group" {
  value = try(module.scheduler[0].main_security_group, null)
}




output "pirana_target_group" {
  value = try(module.pirana[0].listener_rule, null)
}

output "pirana_task_definition" {
  value = try(module.pirana[0].task_definition, null)
}

output "pirana_service" {
  value = try(module.pirana[0].service, null)
}

output "pirana_listener_rule" {
  value = try(module.pirana[0].listener_rule, null)
}

output "pirana_security_group" {
  value = try(module.pirana[0].main_security_group, null)
}


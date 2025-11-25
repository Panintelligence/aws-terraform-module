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
  value = module.lambda.lambda_function #
}

output "efs_lambda_role" {
  value = module.lambda.lambda_role
}

output "efs_lambda_security_group" {
  value = module.lambda.lambda_security_group
}




output "dashboard_internal_target_group" {
  value = module.dashboard[0].internal_target_group
}

output "dashboard_external_target_group" {
  value = module.dashboard[0].external_listener_rule
}

output "dashboard_task_definition" {
  value = module.dashboard[0].task_definition
}

output "dashboard_service" {
  value = module.dashboard[0].service
}

output "dashboard_external_listener_rule" {
  value = module.dashboard[0].external_listener_rule
}

output "dashboard_internal_listener_rule" {
  value = module.dashboard[0].internal_listener_rule
}

output "dashboard_security_group" {
  value = module.dashboard[0].main_security_group
}




output "renderer_target_group" {
  value = module.renderer[0].listener_rule
}

output "renderer_task_definition" {
  value = module.renderer[0].task_definition
}

output "renderer_service" {
  value = module.renderer[0].service
}

output "renderer_listener_rule" {
  value = module.renderer[0].listener_rule
}

output "renderer_security_group" {
  value = module.renderer[0].main_security_group
}




output "scheduler_target_group" {
  value = module.scheduler[0].listener_rule
}

output "scheduler_task_definition" {
  value = module.scheduler[0].task_definition
}

output "scheduler_service" {
  value = module.scheduler[0].service
}

output "scheduler_listener_rule" {
  value = module.scheduler[0].listener_rule
}

output "scheduler_security_group" {
  value = module.scheduler[0].main_security_group
}




output "pirana_target_group" {
  value = module.pirana[0].listener_rule
}

output "pirana_task_definition" {
  value = module.pirana[0].task_definition
}

output "pirana_service" {
  value = module.pirana[0].service
}

output "pirana_listener_rule" {
  value = module.pirana[0].listener_rule
}

output "pirana_security_group" {
  value = module.pirana[0].main_security_group
}


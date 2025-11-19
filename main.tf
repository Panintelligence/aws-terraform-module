
#search tags for all resources 'Billing'
#TODO: security groups for the ecs services. Assuming load balancer?
# Create a sg for each resource. Create an allow all outbound at least manage rules through separate resources, to allow adding extra rules

# add efs sec group to dashboard, lambda and scheduler

module "ecs" {
  source = "./modules/ecs"
  deployment_name = var.deployment_name
  container_insights_setting = var.container_insights_setting
  docker_hub_secrets_arn = var.docker_hub_secrets_arn
}

module "efs" {
  source = "./modules/efs"
  application_subnet_ids = var.application_subnet_ids
  deployment_name       = var.deployment_name
  efs_backup_vault_cron = var.efs_backup_vault_cron
}

module "lambda" {
  source = "./modules/efs_setup"
  application_subnet_ids = var.application_subnet_ids
  dashboard_efs_id = module.efs.efs_file_system.id
  deployment_name = var.deployment_name
  efs_security_group_id = module.efs.efs_security_group.id
}



module "dashboard" {
  #todo: optional
  source = "./modules/dashboard"
  application_subnet_ids = var.application_subnet_ids
  dashboard_cpu = var.dashboard_cpu
  #todo: var, otherwise module
  dashboard_efs_id = module.efs.efs_file_system.id
  docker_image = var.dashboard_image
  dashboard_memory = var.dashboard_memory
  dashboard_private_domain = var.dashboard_private_domain
  dashboard_public_domain = var.dashboard_public_domain
  # todo: if efs created in module
  dashboard_sec_groups_ids = var.dashboard_sec_groups_ids
  deployment_name = var.deployment_name
  # todo: make optional within module in case secret not needed
  docker_hub_secrets_arn = var.docker_hub_secrets_arn
  # todo: add var to override role arns
  execution_role_arn = module.ecs.ecs_task_execution_role.arn
  task_role_arn = module.ecs.ecs_task_role.arn
  alb_listener_external_arn = var.dashboard_alb_listener_external_arn
  alb_listener_internal_arn = var.dashboard_alb_listener_internal_arn
  aws_ecs_cluster_id = module.ecs.ecs_cluster.id
  efs_security_group_id = module.efs.efs_security_group.id
  database_env_vars = var.database_env_vars
  task_env_vars = var.dashboard_task_env_vars
  private_alb_sg_id = var.private_alb_sg_id
  public_alb_sg_id = var.public_alb_sg_id
}
#
# module "scheduler" {
#   source = "./modules/scheduler"
#   alb_listener_arn = var.scheduler_alb_listener_arn
#   application_subnet_ids = var.application_subnet_ids
#   aws_ecs_cluster_id = module.ecs.ecs_cluster.id
#   dashboard_efs_id = module.efs.efs_file_system.id
#   deployment_name = var.deployment_name
#   docker_hub_secrets_arn = var.docker_hub_secrets_arn
#   execution_role_arn = module.ecs.ecs_task_execution_role.arn
#   scheduler_cpu = var.scheduler_cpu
#   docker_image = var.scheduler_image
#   scheduler_memory = var.scheduler_memory
#   scheduler_private_domain = var.scheduler_private_domain
#   scheduler_sec_groups_ids = var.scheduler_sec_group_ids
#   task_role_arn = module.ecs.ecs_task_role.arn
#   efs_security_group_id = module.efs.efs_security_group.id
#   database_env_vars = var.database_env_vars
#   task_env_vars = var.scheduler_task_env_vars
# }
#
# module "renderer" {
#   source = "./modules/renderer"
#   alb_listener_arn = var.renderer_alb_listener_arn
#   application_subnet_ids = var.application_subnet_ids
#   aws_ecs_cluster_id = module.ecs.ecs_cluster.id
#   deployment_name = var.deployment_name
#   docker_hub_secrets_arn = ""
#   execution_role_arn = module.ecs.ecs_task_execution_role.arn
#   renderer_cpu = 0
#   docker_image = ""
#   renderer_memory = 0
#   renderer_private_domain = ""
#   renderer_sec_group_ids = []
#   task_role_arn = ""
#   task_env_vars = var.renderer_task_env_vars
# }
#
# module "pirana" {
#   source = "./modules/pirana"
#   alb_listener_arn= var.pirana_alb_listener_arn
#   application_subnet_ids = var.application_subnet_ids
#   aws_ecs_cluster_id = ""
#   deployment_name = ""
#   docker_hub_secrets_arn = ""
#   execution_role_arn = module.ecs.ecs_task_execution_role.arn
#   pirana_cpu = 0
#   docker_image = ""
#   pirana_memory = 0
#   pirana_private_domain = ""
#   pirana_sec_group_ids = []
#   task_role_arn = ""
#   task_env_vars = var.pirana_task_env_vars
# }
# TODO: rds module
# TODO maybe alb module
# TODO: pipeline to automatically do tf docs and formatting

module "ecs" {
  #todo: option to run within existing cluster
  #todo: option to not fargate
  source                     = "./modules/ecs"
  deployment_name            = var.deployment_name
  container_insights_setting = var.container_insights_setting
  secrets_allowed_arns       = compact([var.docker_hub_secrets_arn, var.db_credentials_secret_arn])
  enable_execute_command     = var.enable_execute_command
}


module "efs" {
  source                   = "./modules/efs"
  application_subnet_ids   = var.application_subnet_ids
  deployment_name          = var.deployment_name
  efs_backup_vault_cron    = var.efs_backup_vault_cron
  efs_backup_force_destroy = var.efs_backup_force_destroy
}

module "lambda" {
  #TODO: update python code, particularly to make it an env var for db name to set up.  - lookup on the value from db_env_vars if exists? otherwise dashboard
  source = "./modules/efs_setup"
  count  = var.set_up_efs ? 1 : 0

  application_subnet_ids = var.application_subnet_ids
  dashboard_efs_id       = module.efs.efs_file_system.id
  deployment_name        = var.deployment_name
  efs_security_group_id  = module.efs.efs_security_group.id

  depends_on = [module.efs.efs_mount_target_ids] #forcing this module to wait for mount points to become ready TODO: check if this works
}



module "dashboard" {
  source = "./modules/dashboard"
  count  = var.create_dashboard ? 1 : 0

  application_subnet_ids   = var.application_subnet_ids
  dashboard_cpu            = var.dashboard_cpu
  dashboard_efs_id         = module.efs.efs_file_system.id
  docker_image             = var.dashboard_image
  dashboard_memory         = var.dashboard_memory
  dashboard_sec_groups_ids = var.dashboard_sec_groups_ids
  deployment_name          = var.deployment_name
  docker_hub_secrets_arn   = var.docker_hub_secrets_arn
  # todo: add var to override role arns
  execution_role_arn        = module.ecs.ecs_task_execution_role.arn
  task_role_arn             = module.ecs.ecs_task_role.arn
  aws_ecs_cluster_id        = module.ecs.ecs_cluster.id
  efs_security_group_id     = module.efs.efs_security_group.id
  database_env_vars         = var.database_env_vars
  db_credentials_secret_arn = var.db_credentials_secret_arn
  task_env_vars             = var.dashboard_task_env_vars
  enable_execute_command    = var.enable_execute_command

  external_networking_enabled = var.dashboard_external_networking_enabled
  alb_listener_external_arn   = var.dashboard_alb_listener_external_arn
  external_alb_sg_id          = var.dashboard_external_alb_sg_id
  dashboard_public_domain     = var.dashboard_public_domain

  internal_networking_enabled = var.dashboard_internal_networking_enabled
  alb_listener_internal_arn   = var.dashboard_alb_listener_internal_arn
  internal_alb_sg_id          = var.dashboard_internal_alb_sg_id
  dashboard_private_domain    = var.dashboard_private_domain
  desired_count               = var.dashboard_desired_count
}


module "scheduler" {
  source = "./modules/scheduler"
  count  = var.create_scheduler ? 1 : 0

  alb_listener_arn = coalesce(var.scheduler_alb_listener_arn, var.dashboard_alb_listener_internal_arn, var.dashboard_alb_listener_external_arn, "none")
  application_subnet_ids      = var.application_subnet_ids
  aws_ecs_cluster_id          = module.ecs.ecs_cluster.id
  dashboard_efs_id            = module.efs.efs_file_system.id
  deployment_name             = var.deployment_name
  docker_hub_secrets_arn      = var.docker_hub_secrets_arn
  execution_role_arn          = module.ecs.ecs_task_execution_role.arn
  scheduler_cpu               = var.scheduler_cpu
  docker_image                = var.scheduler_image
  scheduler_memory            = var.scheduler_memory
  scheduler_private_domain    = var.scheduler_private_domain
  scheduler_sec_groups_ids    = var.scheduler_sec_group_ids
  task_role_arn               = module.ecs.ecs_task_role.arn
  efs_security_group_id       = module.efs.efs_security_group.id
  database_env_vars           = var.database_env_vars
  db_credentials_secret_arn   = var.db_credentials_secret_arn
  task_env_vars               = var.scheduler_task_env_vars
  alb_sg_id                   = coalesce(var.scheduler_alb_sg_id, var.dashboard_internal_alb_sg_id, var.dashboard_external_alb_sg_id)
  enable_execute_command      = var.enable_execute_command
  internal_networking_enabled = var.dashboard_internal_networking_enabled
  desired_count               = var.scheduler_desired_count
}

module "renderer" {
  source = "./modules/renderer"
  count  = var.create_renderer ? 1 : 0

  alb_listener_arn        = coalesce(var.renderer_alb_listener_arn, var.dashboard_alb_listener_internal_arn, var.dashboard_alb_listener_external_arn, "none")
  application_subnet_ids  = var.application_subnet_ids
  aws_ecs_cluster_id      = module.ecs.ecs_cluster.id
  deployment_name         = var.deployment_name
  docker_hub_secrets_arn  = var.docker_hub_secrets_arn
  execution_role_arn      = module.ecs.ecs_task_execution_role.arn
  renderer_cpu            = var.renderer_cpu
  docker_image            = var.renderer_image
  renderer_memory         = var.renderer_memory
  renderer_private_domain = var.renderer_private_domain
  renderer_sec_group_ids  = var.renderer_sec_group_ids
  task_role_arn           = module.ecs.ecs_task_role.arn
  task_env_vars           = var.renderer_task_env_vars
  alb_sg_id               = coalesce(var.renderer_alb_sg_id, var.dashboard_internal_alb_sg_id, var.dashboard_external_alb_sg_id)
  enable_execute_command  = var.enable_execute_command
  internal_networking_enabled = var.dashboard_internal_networking_enabled
  desired_count           = var.renderer_desired_count
}

module "pirana" {
  source = "./modules/pirana"
  count  = var.create_pirana ? 1 : 0

  alb_listener_arn       = coalesce(var.pirana_alb_listener_arn, var.dashboard_alb_listener_internal_arn, var.dashboard_alb_listener_external_arn, "none")
  application_subnet_ids = var.application_subnet_ids
  aws_ecs_cluster_id     = module.ecs.ecs_cluster.id
  deployment_name        = var.deployment_name
  docker_hub_secrets_arn = var.docker_hub_secrets_arn
  execution_role_arn     = module.ecs.ecs_task_execution_role.arn
  pirana_cpu             = var.pirana_cpu
  docker_image           = var.pirana_image
  pirana_memory          = var.pirana_memory
  pirana_private_domain  = var.pirana_private_domain
  pirana_sec_group_ids   = var.pirana_sec_group_ids
  task_role_arn          = module.ecs.ecs_task_role.arn
  task_env_vars          = var.pirana_task_env_vars
  alb_sg_id              = coalesce(var.pirana_alb_sg_id, var.dashboard_internal_alb_sg_id, var.dashboard_external_alb_sg_id)
  enable_execute_command = var.enable_execute_command
  desired_count          = var.pirana_desired_count
}



module "ai_resource" {
  source = "./modules/ai_resources"
  count = var.create_qdrant ? 1 : 0

  alb_listener_arn = coalesce(var.qdrant_alb_listener_arn, var.dashboard_alb_listener_internal_arn, var.dashboard_alb_listener_external_arn, "none")
  alb_sg_id = coalesce(var.pirana_alb_sg_id, var.dashboard_internal_alb_sg_id, var.dashboard_external_alb_sg_id)
  application_subnet_ids = var.application_subnet_ids
  aws_ecs_cluster_id = module.ecs.ecs_cluster.id
  desired_count =  var.qdrant_desired_count
  docker_image = var.qdrant_image
  enable_execute_command = var.enable_execute_command
  execution_role_arn = module.ecs.ecs_task_execution_role.arn
  qdrant_cpu = var.qdrant_cpu
  qdrant_memory = var.qdrant_memory
  qdrant_private_domain = var.qdrant_private_domain
  task_env_vars = var.qdrant_task_env_vars
  task_role_arn = module.ecs.ecs_task_role.arn
  deployment_name = var.deployment_name
}


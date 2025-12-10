variable "deployment_name" {
  description = "Name of the deployment. Used to name your resources"
  type        = string
  default     = "panintelligence"
}

#### ECS SETTINGS ####

variable "container_insights_setting" {
  description = "Container Insights setting. Valid values are enabled or disabled"
  type        = string
  default     = "disabled"
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for the tasks."
  type        = bool
  default     = false
}

variable "application_subnet_ids" {
  description = "Subnets where the ECS tasks and EFS mount points will be deployed. Choose private subnets within your VPC"
  type        = list(string)
}

#### EFS SETTINGS ####

variable "efs_backup_vault_cron" {
  description = "Cron expression for the EFS backup schedule"
  type        = string
  default     = "cron(0 18 * * ? *)"
}

variable "efs_backup_force_destroy" {
  description = "Whether terraform destroy should force destroy the EFS backup vault. Use with caution!"
  type        = bool
  default     = false
}

variable "set_up_efs" {
  description = "Whether to set up EFS (using lambda) with the structure required by the dashboard and scheduler"
  type        = bool
  default     = true
}
#### COMMON CONTAINER SETTINGS ####

variable "docker_hub_secrets_arn" {
  description = "ARN of the Docker Hub secrets in secrets manager. Consists of username and password key value pairs. Optional if using ECR"
  type        = string
  default     = null
}

variable "database_env_vars" {
  description = "Environment variables shared by dashboard and scheduler, for connecting to the repository database"
  type = object({
    PI_DB_HOST        = string,
    PI_DB_PASSWORD    = string,
    PI_DB_PORT        = string,
    PI_DB_SCHEMA_NAME = string,
    PI_DB_USERNAME    = string
  })
  default = null
}

#### DASHBOARD VARIABLES ####

variable "create_dashboard" {
  description = "Create the dashboard ECS service and resources"
  default     = true
  type        = bool
}
variable "dashboard_cpu" {
  description = "CPU units for the dashboard ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 1024
}
variable "dashboard_memory" {
  description = "Memory for the dashboard ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 2048
}
variable "dashboard_image" {
  description = "Docker image for the dashboard ECS task, including version tag"
  type        = string
  default     = "ghcr.io/pi-cr/server:2025_10.1"
}
variable "dashboard_private_domain" {
  description = "Private domain for the dashboard ECS service networking. Must be resolvable from within the VPC"
  type        = string
  default     = null
}
variable "dashboard_public_domain" {
  description = "Public domain for the dashboard ECS service networking. Must be resolvable from the internet"
  type        = string
  default     = null
}
variable "dashboard_sec_groups_ids" {
  description = "Additional security groups to attach to the dashboard ECS service"
  type        = list(string)
  default     = []
}
variable "dashboard_alb_listener_external_arn" {
  description = "ARN of the external ALB listener for the dashboard ECS service, for which a rule will be created. Listener for HTTPS port 443 recommended"
  type        = string
  default     = null
}
variable "dashboard_alb_listener_internal_arn" {
  description = "ARN of the internal ALB listener for the dashboard ECS service, for which a rule will be created"
  type        = string
  default     = null
}
variable "dashboard_task_env_vars" {
  description = "An object consisting of key value pairs for environment variables to be passed to the dashboard ECS task. Format is {VARIABLE_NAME = 'VALUE'} "
  type        = any
  default     = null
}
variable "internal_alb_sg_id" {
  description = "Security group ID used by the private ALB, to allow traffic to the dashboard ECS service"
  type        = string
  default     = null
}
variable "external_alb_sg_id" {
  description = "Security group ID used by the public ALB, to allow traffic to the dashboard ECS service"
  type        = string
  default     = null
}
variable "dashboard_external_networking_enabled" {
  description = "Enable to use the 8224 internal port for dashboard"
  type = bool
  default = true
}
variable "dashboard_internal_networking_enabled" {
  description = "Enable to use the 28748 external port for dashboard"
  type = bool
  default = true
}

#### SCHEDULER VARIABLES ####

variable "create_scheduler" {
  description = "Create the scheduler ECS service and resources"
  default     = true
  type        = bool
}

variable "scheduler_alb_listener_arn" {
  description = "ARN of the ALB listener for the scheduler ECS service, for which a rule will be created. Using a private ALB is recommended"
  type        = string
  default     = null
}
variable "scheduler_cpu" {
  description = "CPU units for the scheduler ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 256
}
variable "scheduler_memory" {
  description = "Memory for the scheduler ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 512
}
variable "scheduler_image" {
  description = "Docker image for the scheduler ECS task, including version tag"
  type        = string
  default     = "ghcr.io/pi-cr/scheduler:2025_10.1"
}
variable "scheduler_private_domain" {
  description = "Private domain for the scheduler ECS service networking. Must be resolvable from within the VPC"
  type        = string
  default     = null
}
variable "scheduler_sec_group_ids" {
  description = "Additional security groups to attach to the scheduler ECS service"
  type        = list(string)
  default     = []
}
variable "scheduler_task_env_vars" {
  description = "An object consisting of key value pairs for environment variables to be passed to the scheduler ECS task. Format is {VARIABLE_NAME = 'VALUE'} "
  type        = any
  default     = {}
}

#### RENDERER VARIABLES ####

variable "create_renderer" {
  description = "Create the renderer ECS service and resources"
  default     = true
  type        = bool
}
variable "renderer_alb_listener_arn" {
  description = "ARN of the ALB listener for the renderer ECS service, for which a rule will be created. Using a private ALB is recommended"
  type        = string
  default     = null
}
variable "renderer_cpu" {
  description = "CPU units for the renderer ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 1024
}
variable "renderer_memory" {
  description = "Memory for the renderer ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 2048
}
variable "renderer_image" {
  description = "Docker image for the renderer ECS task, including version tag"
  type        = string
  default     = "ghcr.io/pi-cr/renderer:2025_10.1"
}
variable "renderer_private_domain" {
  description = "Private domain for the renderer ECS service networking. Must be resolvable from within the VPC"
  type        = string
  default     = null
}
variable "renderer_sec_group_ids" {
  description = "Additional security groups to attach to the renderer ECS service"
  type        = list(string)
  default     = []
}
variable "renderer_task_env_vars" {
  description = "An object consisting of key value pairs for environment variables to be passed to the renderer ECS task. Format is {VARIABLE_NAME = 'VALUE'} "
  type        = any
  default     = {}
}


#### PIRANA VARIABLES ####

variable "create_pirana" {
  description = "Create the pirana ECS service and resources"
  default     = true
  type        = bool
}
variable "pirana_alb_listener_arn" {
  description = "ARN of the ALB listener for the pirana ECS service, for which a rule will be created. Using a private ALB is recommended"
  type        = string
  default     = null
}
variable "pirana_cpu" {
  description = "CPU units for the pirana ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 1024
}
variable "pirana_memory" {
  description = "Memory for the pirana ECS task. Choose valid Fargate sizing"
  type        = number
  default     = 2048
}
variable "pirana_image" {
  description = "Docker image for the pirana ECS task, including version tag"
  type        = string
  default     = "ghcr.io/pi-cr/pirana:2025_10.1"
}

variable "pirana_private_domain" {
  description = "Private domain for the pirana ECS service networking. Must be resolvable from within the VPC"
  type        = string
  default     = null
}
variable "pirana_sec_group_ids" {
  description = "Additional security groups to attach to the pirana ECS service"
  type        = list(string)
  default     = []
}
variable "pirana_task_env_vars" {
  description = "An object consisting of key value pairs for environment variables to be passed to the pirana ECS task. Format is {VARIABLE_NAME = 'VALUE'} "
  type        = any
  default     = {}
}
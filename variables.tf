variable "deployment_name" {
  type = string
  default = "panintelligence"
}

variable "container_insights_setting" {
  type = string
  default = "disabled"
}
variable "application_subnet_ids" {
  type = list(string)
}
variable "efs_backup_vault_cron" {
  type = string
  default = "cron(0 18 * * ? *)"
}

variable "docker_hub_secrets_arn" {
  type = string
}


variable "dashboard_cpu" {
  default = 1024
}
variable "dashboard_image" {
  default = "ghcr.io/pi-cr/server:2025_10.1"
}
variable "dashboard_memory" {
  default = 2048
}
variable "dashboard_private_domain" {
  type = string
}
variable "dashboard_public_domain" {
  type = string
}
variable "dashboard_sec_groups_ids" {
  default = []
}
variable "dashboard_alb_listener_external_arn" {
  type = string
}
variable "dashboard_alb_listener_internal_arn" {
  type = string
}
variable "database_env_vars" {
  type = object({
    PI_DB_HOST = string,
    PI_DB_PASSWORD = string,
    PI_DB_PORT = string,
    PI_DB_SCHEMA_NAME = string,
    PI_DB_USERNAME = string
  })
}
variable "dashboard_task_env_vars" {
  type = any
}

variable "private_alb_sg_id" {
  type = string
}
variable "public_alb_sg_id" {
  type = string
}



variable "scheduler_alb_listener_arn" {
  type = string
}
variable "scheduler_cpu" {
  default = 256
}
variable "scheduler_image" {
  default = "ghcr.io/pi-cr/scheduler:2025_10.1"
}
variable "scheduler_memory" {
  default = 512
}
variable "scheduler_private_domain" {
  type = string
}
variable "scheduler_sec_group_ids" {
  default = []
}
variable "scheduler_task_env_vars" {
  type = any
}


variable "renderer_alb_listener_arn" {
  type = string
}

variable "renderer_cpu" {
  default = 1024
}
variable "renderer_image" {
  default = "ghcr.io/pi-cr/renderer:2025_10.1"
}
variable "renderer_memory" {
  default = 2048
}
variable "renderer_private_domain" {
  type = string
}
variable "renderer_sec_group_ids" {
  default = []
}
variable "renderer_task_env_vars" {
  default = {}
}


variable "pirana_alb_listener_arn" {
  type =string
}
variable "pirana_cpu" {
  default = 1024
}
variable "pirana_image" {
  default = "ghcr.io/pi-cr/pirana:2025_10.1"
}
variable "pirana_memory" {
  default = 2048
}
variable "pirana_private_domain" {
  type = string
}
variable "pirana_sec_group_ids" {
  default = []
}
variable "pirana_task_env_vars" {
  default = {}
}
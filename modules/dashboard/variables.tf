variable "deployment_name" {
  type = string
}
variable "dashboard_memory" {
  type = number
}
variable "dashboard_cpu" {
  type = number
}
variable "execution_role_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "dashboard_efs_id" {
  type = string
}
variable "docker_image" {
  type = string
}
variable "docker_hub_secrets_arn" {
  type    = string
  default = ""
}
variable "aws_ecs_cluster_id" {
  type = string
}
variable "application_subnet_ids" {
  type = list(string)
}
variable "dashboard_sec_groups_ids" {
  type    = list(string)
  default = []
}
variable "alb_listener_external_arn" {
  type = string
}
variable "dashboard_public_domain" {
  type = string
}
variable "alb_listener_internal_arn" {
  type = string
}
variable "dashboard_private_domain" {
  type = string
}
variable "efs_security_group_id" {
  type = string
}

variable "task_env_vars" {
  type = any
}

variable "database_env_vars" {
  type = any
}
variable "external_alb_sg_id" {
  type = string
}
variable "internal_alb_sg_id" {
  type = string
}

variable "enable_execute_command" {
  type = bool
}

variable "internal_networking_enabled" {
  type = bool
}
variable "external_networking_enabled" {
  type = bool
}
variable "db_credentials_secret_arn" {
  type = string
}
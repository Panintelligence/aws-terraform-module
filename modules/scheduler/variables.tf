variable "deployment_name" {
  type = string
}
variable "application_subnet_ids" {
  type = list(string)
}
variable "scheduler_sec_groups_ids" {
  type    = list(string)
  default = []
}
variable "scheduler_cpu" {
  type = number
}
variable "docker_hub_secrets_arn" {
  type    = string
  default = ""
}
variable "scheduler_memory" {
  type = number
}
variable "dashboard_efs_id" {
  type = string
}
variable "execution_role_arn" {
  type = string
}
variable "task_role_arn" {
  type = string
}
variable "alb_listener_arn" {
  type = string
}
variable "scheduler_private_domain" {
  type = string
}
variable "aws_ecs_cluster_id" {
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
variable "docker_image" {
  type = string
}
variable "private_alb_sg_id" {
  type = string
}
variable "enable_execute_command" {
  type = bool
}
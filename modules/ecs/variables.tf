variable "deployment_name" {
  type = string
}

variable "container_insights_setting" {
  type = string
}

variable "secrets_allowed_arns" {
  type = list(string)
}

variable "enable_execute_command" {
  type = bool
}
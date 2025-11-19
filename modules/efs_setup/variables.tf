variable "deployment_name" {
  type = string
}

variable "dashboard_efs_id" {
  type = string
}
variable "application_subnet_ids" {
  type = list(string)
}

variable "efs_security_group_id" {
  type = string
}
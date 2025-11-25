variable "deployment_name" {
  type = string
}

variable "application_subnet_ids" {
  type = list(string)
}

variable "efs_backup_vault_cron" {
  type = string
}
variable "efs_backup_force_destroy" {
  type = bool
}
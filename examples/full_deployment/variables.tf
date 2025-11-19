variable "domain_name" {
  type = string
}

variable "private_domain_name" {
  type = string
}

variable "deployment_name" {
  default = "panintelligence"
}

variable "licence" {}

variable "docker_secret_arn" {
  type = string
}

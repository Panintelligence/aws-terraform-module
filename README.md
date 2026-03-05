# aws-terraform-module
Terraform module to deploy Pi Dashboard software to AWS using an ECS cluster

Resources created in this module:
- an ECS cluster with four services - panintelligence dashboard, scheduler, renderer and pirana
- EFS backed persistent storage, configured using Lambda, for dashboard data such as themes and keys

This module is created to enable a minimal deployment into your existing AWS infrastructure, assuming networking is already in place. 
A full example of how this module can be used, with supporting resources configured, can be seen in the /examples folder. 
This provides a fully functional configuration out of the box (aside from a registered domain)

## Available Features
- Deployment of services is optional - for dashboard, scheduler, pirana and renderer
- Enable or disable ecs exec command functionality - for debugging
- Dashboard support of public and/or internal networking - you can choose to enable or disable them independently


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.80 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_resource"></a> [ai\_resource](#module\_ai\_resource) | ./modules/ai_resources | n/a |
| <a name="module_dashboard"></a> [dashboard](#module\_dashboard) | ./modules/dashboard | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | ./modules/efs | n/a |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ./modules/efs_setup | n/a |
| <a name="module_pirana"></a> [pirana](#module\_pirana) | ./modules/pirana | n/a |
| <a name="module_renderer"></a> [renderer](#module\_renderer) | ./modules/renderer | n/a |
| <a name="module_scheduler"></a> [scheduler](#module\_scheduler) | ./modules/scheduler | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_subnet_ids"></a> [application\_subnet\_ids](#input\_application\_subnet\_ids) | Subnets where the ECS tasks and EFS mount points will be deployed. Choose private subnets within your VPC | `list(string)` | n/a | yes |
| <a name="input_container_insights_setting"></a> [container\_insights\_setting](#input\_container\_insights\_setting) | Container Insights setting. Valid values are enabled or disabled | `string` | `"disabled"` | no |
| <a name="input_create_dashboard"></a> [create\_dashboard](#input\_create\_dashboard) | Create the dashboard ECS service and resources | `bool` | `true` | no |
| <a name="input_create_pirana"></a> [create\_pirana](#input\_create\_pirana) | Create the pirana ECS service and resources | `bool` | `true` | no |
| <a name="input_create_qdrant"></a> [create\_qdrant](#input\_create\_qdrant) | create qdrant resources | `bool` | `true` | no |
| <a name="input_create_renderer"></a> [create\_renderer](#input\_create\_renderer) | Create the renderer ECS service and resources | `bool` | `true` | no |
| <a name="input_create_scheduler"></a> [create\_scheduler](#input\_create\_scheduler) | Create the scheduler ECS service and resources | `bool` | `true` | no |
| <a name="input_dashboard_alb_listener_external_arn"></a> [dashboard\_alb\_listener\_external\_arn](#input\_dashboard\_alb\_listener\_external\_arn) | ARN of the external ALB listener for the dashboard ECS service, for which a rule will be created. Listener for HTTPS port 443 recommended | `string` | `null` | no |
| <a name="input_dashboard_alb_listener_internal_arn"></a> [dashboard\_alb\_listener\_internal\_arn](#input\_dashboard\_alb\_listener\_internal\_arn) | ARN of the internal ALB listener for the dashboard ECS service, for which a rule will be created | `string` | `null` | no |
| <a name="input_dashboard_cpu"></a> [dashboard\_cpu](#input\_dashboard\_cpu) | CPU units for the dashboard ECS task. Choose valid Fargate sizing | `number` | `1024` | no |
| <a name="input_dashboard_desired_count"></a> [dashboard\_desired\_count](#input\_dashboard\_desired\_count) | Desired number of dashboard instances. Setting to 0 disables the service and target group. | `number` | `1` | no |
| <a name="input_dashboard_external_alb_sg_id"></a> [dashboard\_external\_alb\_sg\_id](#input\_dashboard\_external\_alb\_sg\_id) | Security group ID used by the public ALB, to allow traffic to ECS services | `string` | `null` | no |
| <a name="input_dashboard_external_networking_enabled"></a> [dashboard\_external\_networking\_enabled](#input\_dashboard\_external\_networking\_enabled) | Enable to use the 8224 internal port for dashboard | `bool` | `true` | no |
| <a name="input_dashboard_image"></a> [dashboard\_image](#input\_dashboard\_image) | Docker image for the dashboard ECS task, including version tag | `string` | `"ghcr.io/pi-cr/server:2025_10.1"` | no |
| <a name="input_dashboard_internal_alb_sg_id"></a> [dashboard\_internal\_alb\_sg\_id](#input\_dashboard\_internal\_alb\_sg\_id) | Security group ID used by the private ALB, to allow traffic to ECS services | `string` | `null` | no |
| <a name="input_dashboard_internal_networking_enabled"></a> [dashboard\_internal\_networking\_enabled](#input\_dashboard\_internal\_networking\_enabled) | Enable to use the 28748 external port for dashboard | `bool` | `true` | no |
| <a name="input_dashboard_memory"></a> [dashboard\_memory](#input\_dashboard\_memory) | Memory for the dashboard ECS task. Choose valid Fargate sizing | `number` | `2048` | no |
| <a name="input_dashboard_private_domain"></a> [dashboard\_private\_domain](#input\_dashboard\_private\_domain) | Private domain for the dashboard ECS service networking. Must be resolvable from within the VPC | `string` | `null` | no |
| <a name="input_dashboard_public_domain"></a> [dashboard\_public\_domain](#input\_dashboard\_public\_domain) | Public domain for the dashboard ECS service networking. Must be resolvable from the internet | `string` | `null` | no |
| <a name="input_dashboard_sec_groups_ids"></a> [dashboard\_sec\_groups\_ids](#input\_dashboard\_sec\_groups\_ids) | Additional security groups to attach to the dashboard ECS service | `list(string)` | `[]` | no |
| <a name="input_dashboard_task_env_vars"></a> [dashboard\_task\_env\_vars](#input\_dashboard\_task\_env\_vars) | An object consisting of key value pairs for environment variables to be passed to the dashboard ECS task. Format is {VARIABLE\_NAME = 'VALUE'} | `any` | `{}` | no |
| <a name="input_database_env_vars"></a> [database\_env\_vars](#input\_database\_env\_vars) | Environment variables shared by dashboard and scheduler, for connecting to the repository database. Credentials can be supplied through `db_credentials_secret_arn` instead | <pre>object({<br/>    PI_DB_HOST        = string,<br/>    PI_DB_PASSWORD    = optional(string, null),<br/>    PI_DB_PORT        = string,<br/>    PI_DB_SCHEMA_NAME = string,<br/>    PI_DB_USERNAME    = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_db_credentials_secret_arn"></a> [db\_credentials\_secret\_arn](#input\_db\_credentials\_secret\_arn) | ARN of the secret containing the database credentials. Secret must contain a `username` and `password` key | `string` | `null` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name of the deployment. Used to name your resources | `string` | `"panintelligence"` | no |
| <a name="input_docker_hub_secrets_arn"></a> [docker\_hub\_secrets\_arn](#input\_docker\_hub\_secrets\_arn) | ARN of the Docker Hub secrets in secrets manager. Consists of username and password key value pairs. Optional if using ECR | `string` | `null` | no |
| <a name="input_efs_backup_force_destroy"></a> [efs\_backup\_force\_destroy](#input\_efs\_backup\_force\_destroy) | Whether terraform destroy should force destroy the EFS backup vault. Use with caution! | `bool` | `false` | no |
| <a name="input_efs_backup_vault_cron"></a> [efs\_backup\_vault\_cron](#input\_efs\_backup\_vault\_cron) | Cron expression for the EFS backup schedule | `string` | `"cron(0 18 * * ? *)"` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS Exec for the tasks. | `bool` | `false` | no |
| <a name="input_pirana_alb_listener_arn"></a> [pirana\_alb\_listener\_arn](#input\_pirana\_alb\_listener\_arn) | ARN of the ALB listener for the pirana ECS service, for which a rule will be created, if different from the dashboard. Using a private ALB is recommended | `string` | `null` | no |
| <a name="input_pirana_alb_sg_id"></a> [pirana\_alb\_sg\_id](#input\_pirana\_alb\_sg\_id) | Security group ID used by the ALB, to allow traffic to pirana ECS services, if different from the dashboard | `string` | `null` | no |
| <a name="input_pirana_cpu"></a> [pirana\_cpu](#input\_pirana\_cpu) | CPU units for the pirana ECS task. Choose valid Fargate sizing | `number` | `1024` | no |
| <a name="input_pirana_desired_count"></a> [pirana\_desired\_count](#input\_pirana\_desired\_count) | Desired number of pirana instances. Setting to 0 disables the service and target group. | `number` | `1` | no |
| <a name="input_pirana_image"></a> [pirana\_image](#input\_pirana\_image) | Docker image for the pirana ECS task, including version tag | `string` | `"ghcr.io/pi-cr/pirana:2025_10.1"` | no |
| <a name="input_pirana_memory"></a> [pirana\_memory](#input\_pirana\_memory) | Memory for the pirana ECS task. Choose valid Fargate sizing | `number` | `2048` | no |
| <a name="input_pirana_private_domain"></a> [pirana\_private\_domain](#input\_pirana\_private\_domain) | Private domain for the pirana ECS service networking. Must be resolvable from within the VPC | `string` | `null` | no |
| <a name="input_pirana_sec_group_ids"></a> [pirana\_sec\_group\_ids](#input\_pirana\_sec\_group\_ids) | Additional security groups to attach to the pirana ECS service | `list(string)` | `[]` | no |
| <a name="input_pirana_task_env_vars"></a> [pirana\_task\_env\_vars](#input\_pirana\_task\_env\_vars) | An object consisting of key value pairs for environment variables to be passed to the pirana ECS task. Format is {VARIABLE\_NAME = 'VALUE'} | `any` | `{}` | no |
| <a name="input_qdrant_alb_listener_arn"></a> [qdrant\_alb\_listener\_arn](#input\_qdrant\_alb\_listener\_arn) | ARN of the ALB listener for the qdrant ECS service, for which a rule will be created, if different from the dashboard. Using a private ALB is recommended | `string` | `null` | no |
| <a name="input_qdrant_cpu"></a> [qdrant\_cpu](#input\_qdrant\_cpu) | The cpu to allocate to the qdrant container | `number` | `1024` | no |
| <a name="input_qdrant_desired_count"></a> [qdrant\_desired\_count](#input\_qdrant\_desired\_count) | Desired number of qdrant instances | `number` | `1` | no |
| <a name="input_qdrant_image"></a> [qdrant\_image](#input\_qdrant\_image) | The image to use for the qdrant container | `string` | `"qdrant/qdrant:latest"` | no |
| <a name="input_qdrant_memory"></a> [qdrant\_memory](#input\_qdrant\_memory) | The memory to allocat to the qdrant container | `number` | `4096` | no |
| <a name="input_qdrant_private_domain"></a> [qdrant\_private\_domain](#input\_qdrant\_private\_domain) | Private domain for the qdrant ECS service networking. Must be resolvable from within the VPC | `string` | `null` | no |
| <a name="input_qdrant_task_env_vars"></a> [qdrant\_task\_env\_vars](#input\_qdrant\_task\_env\_vars) | An object consisting of key value pairs for environment variables to be passed to the qdrant ECS task. Format is {VARIABLE\_NAME = 'VALUE'} | `any` | `{}` | no |
| <a name="input_renderer_alb_listener_arn"></a> [renderer\_alb\_listener\_arn](#input\_renderer\_alb\_listener\_arn) | ARN of the ALB listener for the renderer ECS service, for which a rule will be created, if different from the dashboard. Using a private ALB is recommended | `string` | `null` | no |
| <a name="input_renderer_alb_sg_id"></a> [renderer\_alb\_sg\_id](#input\_renderer\_alb\_sg\_id) | Security group ID used by the ALB, to allow traffic to renderer ECS services, if different from the dashboard | `string` | `null` | no |
| <a name="input_renderer_cpu"></a> [renderer\_cpu](#input\_renderer\_cpu) | CPU units for the renderer ECS task. Choose valid Fargate sizing | `number` | `1024` | no |
| <a name="input_renderer_desired_count"></a> [renderer\_desired\_count](#input\_renderer\_desired\_count) | Desired number of renderer instances. Setting to 0 disables the service and target group. | `number` | `1` | no |
| <a name="input_renderer_image"></a> [renderer\_image](#input\_renderer\_image) | Docker image for the renderer ECS task, including version tag | `string` | `"ghcr.io/pi-cr/renderer:2025_10.1"` | no |
| <a name="input_renderer_memory"></a> [renderer\_memory](#input\_renderer\_memory) | Memory for the renderer ECS task. Choose valid Fargate sizing | `number` | `2048` | no |
| <a name="input_renderer_private_domain"></a> [renderer\_private\_domain](#input\_renderer\_private\_domain) | Private domain for the renderer ECS service networking. Must be resolvable from within the VPC | `string` | `null` | no |
| <a name="input_renderer_sec_group_ids"></a> [renderer\_sec\_group\_ids](#input\_renderer\_sec\_group\_ids) | Additional security groups to attach to the renderer ECS service | `list(string)` | `[]` | no |
| <a name="input_renderer_task_env_vars"></a> [renderer\_task\_env\_vars](#input\_renderer\_task\_env\_vars) | An object consisting of key value pairs for environment variables to be passed to the renderer ECS task. Format is {VARIABLE\_NAME = 'VALUE'} | `any` | `{}` | no |
| <a name="input_scheduler_alb_listener_arn"></a> [scheduler\_alb\_listener\_arn](#input\_scheduler\_alb\_listener\_arn) | ARN of the ALB listener for the scheduler ECS service, for which a rule will be created, if different from the dashboard. Using a private ALB is recommended | `string` | `null` | no |
| <a name="input_scheduler_alb_sg_id"></a> [scheduler\_alb\_sg\_id](#input\_scheduler\_alb\_sg\_id) | Security group ID used by the ALB, to allow traffic to scheduler ECS services, if different from the dashboard | `string` | `null` | no |
| <a name="input_scheduler_cpu"></a> [scheduler\_cpu](#input\_scheduler\_cpu) | CPU units for the scheduler ECS task. Choose valid Fargate sizing | `number` | `256` | no |
| <a name="input_scheduler_desired_count"></a> [scheduler\_desired\_count](#input\_scheduler\_desired\_count) | Desired number of scheduler instances. Setting to 0 disables the service and target group. Number greater than 1 not recommended at this time | `number` | `1` | no |
| <a name="input_scheduler_image"></a> [scheduler\_image](#input\_scheduler\_image) | Docker image for the scheduler ECS task, including version tag | `string` | `"ghcr.io/pi-cr/scheduler:2025_10.1"` | no |
| <a name="input_scheduler_memory"></a> [scheduler\_memory](#input\_scheduler\_memory) | Memory for the scheduler ECS task. Choose valid Fargate sizing | `number` | `512` | no |
| <a name="input_scheduler_private_domain"></a> [scheduler\_private\_domain](#input\_scheduler\_private\_domain) | Private domain for the scheduler ECS service networking. Must be resolvable from within the VPC | `string` | `null` | no |
| <a name="input_scheduler_sec_group_ids"></a> [scheduler\_sec\_group\_ids](#input\_scheduler\_sec\_group\_ids) | Additional security groups to attach to the scheduler ECS service | `list(string)` | `[]` | no |
| <a name="input_scheduler_task_env_vars"></a> [scheduler\_task\_env\_vars](#input\_scheduler\_task\_env\_vars) | An object consisting of key value pairs for environment variables to be passed to the scheduler ECS task. Format is {VARIABLE\_NAME = 'VALUE'} | `any` | `{}` | no |
| <a name="input_set_up_efs"></a> [set\_up\_efs](#input\_set\_up\_efs) | Whether to set up EFS (using lambda) with the structure required by the dashboard and scheduler | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_external_listener_rule"></a> [dashboard\_external\_listener\_rule](#output\_dashboard\_external\_listener\_rule) | n/a |
| <a name="output_dashboard_external_target_group"></a> [dashboard\_external\_target\_group](#output\_dashboard\_external\_target\_group) | n/a |
| <a name="output_dashboard_internal_listener_rule"></a> [dashboard\_internal\_listener\_rule](#output\_dashboard\_internal\_listener\_rule) | n/a |
| <a name="output_dashboard_internal_target_group"></a> [dashboard\_internal\_target\_group](#output\_dashboard\_internal\_target\_group) | n/a |
| <a name="output_dashboard_security_group"></a> [dashboard\_security\_group](#output\_dashboard\_security\_group) | n/a |
| <a name="output_dashboard_service"></a> [dashboard\_service](#output\_dashboard\_service) | n/a |
| <a name="output_dashboard_task_definition"></a> [dashboard\_task\_definition](#output\_dashboard\_task\_definition) | n/a |
| <a name="output_ecs_cluster"></a> [ecs\_cluster](#output\_ecs\_cluster) | n/a |
| <a name="output_ecs_execution_role"></a> [ecs\_execution\_role](#output\_ecs\_execution\_role) | n/a |
| <a name="output_ecs_task_role"></a> [ecs\_task\_role](#output\_ecs\_task\_role) | n/a |
| <a name="output_efs_file_system"></a> [efs\_file\_system](#output\_efs\_file\_system) | n/a |
| <a name="output_efs_lambda"></a> [efs\_lambda](#output\_efs\_lambda) | n/a |
| <a name="output_efs_lambda_role"></a> [efs\_lambda\_role](#output\_efs\_lambda\_role) | n/a |
| <a name="output_efs_lambda_security_group"></a> [efs\_lambda\_security\_group](#output\_efs\_lambda\_security\_group) | n/a |
| <a name="output_efs_security_group"></a> [efs\_security\_group](#output\_efs\_security\_group) | n/a |
| <a name="output_pirana_listener_rule"></a> [pirana\_listener\_rule](#output\_pirana\_listener\_rule) | n/a |
| <a name="output_pirana_security_group"></a> [pirana\_security\_group](#output\_pirana\_security\_group) | n/a |
| <a name="output_pirana_service"></a> [pirana\_service](#output\_pirana\_service) | n/a |
| <a name="output_pirana_target_group"></a> [pirana\_target\_group](#output\_pirana\_target\_group) | n/a |
| <a name="output_pirana_task_definition"></a> [pirana\_task\_definition](#output\_pirana\_task\_definition) | n/a |
| <a name="output_renderer_listener_rule"></a> [renderer\_listener\_rule](#output\_renderer\_listener\_rule) | n/a |
| <a name="output_renderer_security_group"></a> [renderer\_security\_group](#output\_renderer\_security\_group) | n/a |
| <a name="output_renderer_service"></a> [renderer\_service](#output\_renderer\_service) | n/a |
| <a name="output_renderer_target_group"></a> [renderer\_target\_group](#output\_renderer\_target\_group) | n/a |
| <a name="output_renderer_task_definition"></a> [renderer\_task\_definition](#output\_renderer\_task\_definition) | n/a |
| <a name="output_scheduler_listener_rule"></a> [scheduler\_listener\_rule](#output\_scheduler\_listener\_rule) | n/a |
| <a name="output_scheduler_security_group"></a> [scheduler\_security\_group](#output\_scheduler\_security\_group) | n/a |
| <a name="output_scheduler_service"></a> [scheduler\_service](#output\_scheduler\_service) | n/a |
| <a name="output_scheduler_target_group"></a> [scheduler\_target\_group](#output\_scheduler\_target\_group) | n/a |
| <a name="output_scheduler_task_definition"></a> [scheduler\_task\_definition](#output\_scheduler\_task\_definition) | n/a |
<!-- END_TF_DOCS -->
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

## Inputs

| Name                                  | Type         | Default                             | Description                                                                                                |
|---------------------------------------|--------------|-------------------------------------|------------------------------------------------------------------------------------------------------------|
| deployment_name                       | string       | "panintelligence"                   | Name of the deployment. Used to name your resources                                                        |
| container_insights_setting            | string       | "disabled"                          | Container Insights setting. Valid values are enabled or disabled                                           |
| enable_execute_command                | bool         | false                               | Enable ECS Exec for the tasks                                                                              |
| application_subnet_ids                | list(string) | —                                   | Subnets where the ECS tasks and EFS mount points will be deployed                                          |
| set_up_efs                            | bool         | true                                | Whether to set up EFS (using lambda) with the structure required by the dashboard and scheduler            |
| efs_backup_vault_cron                 | string       | "cron(0 18 * * ? *)"                | Cron expression for the EFS backup schedule                                                                |
| efs_backup_force_destroy              | bool         | false                               | Whether terraform destroy should force destroy the EFS backup vault. Use with caution!                     |
| docker_hub_secrets_arn                | string       | null                                | ARN of Docker Hub secrets in Secrets Manager                                                               |
| database_env_vars                     | object       | null                                | Shared environment variables for repository DB connection                                                  |
| db_credentials_secret_arn             | string       | null                                | ARN of the secret containing the database credentials. Secret must contain a `username` and `password` key |
| create_dashboard                      | bool         | true                                | Create the dashboard ECS service and resources                                                             |
| dashboard_cpu                         | number       | 1024                                | CPU units for the dashboard ECS task                                                                       |
| dashboard_memory                      | number       | 2048                                | Memory for the dashboard ECS task                                                                          |
| dashboard_image                       | string       | "ghcr.io/pi-cr/server:2025_10.1"    | Docker image for the dashboard ECS task                                                                    |
| dashboard_private_domain              | string       | null                                | Private domain for dashboard service networking                                                            |
| dashboard_public_domain               | string       | null                                | Public domain for dashboard service networking                                                             |
| dashboard_sec_groups_ids              | list(string) | []                                  | Additional security groups for the dashboard ECS service                                                   |
| dashboard_alb_listener_external_arn   | string       | null                                | External ALB listener ARN for dashboard                                                                    |
| dashboard_alb_listener_internal_arn   | string       | null                                | Internal ALB listener ARN for dashboard                                                                    |
| dashboard_task_env_vars               | any          | null                                | Key/value environment variables for dashboard ECS task                                                     |
| dashboard_external_networking_enabled | bool         | true                                | Enable to use the 8224 internal port for dashboard                                                         |
| dashboard_internal_networking_enabled | bool         | true                                | Enable to use the 28748 external port for dashboard                                                        |
| private_alb_sg_id                     | string       | null                                | Security group ID for private ALB                                                                          |
| public_alb_sg_id                      | string       | null                                | Security group ID for public ALB                                                                           |
| create_scheduler                      | bool         | true                                | Create the scheduler ECS service and resources                                                             |
| scheduler_alb_listener_arn            | string       | null                                | ALB listener ARN for scheduler                                                                             |
| scheduler_cpu                         | number       | 256                                 | CPU units for the scheduler ECS task                                                                       |
| scheduler_memory                      | number       | 512                                 | Memory for the scheduler ECS task                                                                          |
| scheduler_image                       | string       | "ghcr.io/pi-cr/scheduler:2025_10.1" | Docker image for the scheduler ECS task                                                                    |
| scheduler_private_domain              | string       | null                                | Private domain for scheduler networking                                                                    |
| scheduler_sec_group_ids               | list(string) | []                                  | Additional security groups for scheduler                                                                   |
| scheduler_task_env_vars               | any          | {}                                  | Environment variable key/value pairs for scheduler                                                         |
| create_renderer                       | bool         | true                                | Create the renderer ECS service and resources                                                              |
| renderer_alb_listener_arn             | string       | null                                | ALB listener ARN for renderer                                                                              |
| renderer_cpu                          | number       | 1024                                | CPU units for the renderer ECS task                                                                        |
| renderer_memory                       | number       | 2048                                | Memory for the renderer ECS task                                                                           |
| renderer_image                        | string       | "ghcr.io/pi-cr/renderer:2025_10.1"  | Docker image for the renderer ECS task                                                                     |
| renderer_private_domain               | string       | null                                | Private domain for renderer networking                                                                     |
| renderer_sec_group_ids                | list(string) | []                                  | Additional security groups for renderer                                                                    |
| renderer_task_env_vars                | any          | {}                                  | Environment variables for renderer ECS task                                                                |
| create_pirana                         | bool         | true                                | Create the pirana ECS service and resources                                                                |
| pirana_alb_listener_arn               | string       | null                                | ALB listener ARN for pirana                                                                                |
| pirana_cpu                            | number       | 1024                                | CPU units for the pirana ECS task                                                                          |
| pirana_memory                         | number       | 2048                                | Memory for the pirana ECS task                                                                             |
| pirana_image                          | string       | "ghcr.io/pi-cr/pirana:2025_10.1"    | Docker image for the pirana ECS task                                                                       |
| pirana_private_domain                 | string       | null                                | Private domain for pirana service networking                                                               |
| pirana_sec_group_ids                  | list(string) | []                                  | Additional security groups for pirana                                                                      |
| pirana_task_env_vars                  | any          | {}                                  | Environment variables for pirana ECS task                                                                  |


# How to run this example

## Set variables

In the variables.tf file, set:
- "domain_name" a verified route53 hosted zone or delegated zone for the public domain to reach your instance
- "private_domain_name" any valid domain name, does not need to be registered
- "deployment_name" to name your resources, or leave as is
- "licence" A valid licence for the software
- "docker_secret_arn" A secrets manager secret to authenticate to the repository hosting the images, containing username and password/token

## Review the provider

You can change the aws region and tags applied to all resources in the aws provider in the versions.tf file

## How to deploy

The network should be deployed first to avoid a terraform error

- Export your aws credentials (admin access)
- terraform init
- terraform plan -target=module.vpc
- terraform apply -target=module.vpc
- terraform plan
- terraform apply


Export your aws credentials (admin access)
optional - set a remote backend

create a secret in secretsmanager containing docker credentials (username and password/token)
set a valid licence for the panintelligence software

Create a verified route53 hosted zone or delegated zone for the public domain to reach your instance. Set this as the variable "domain_name" 
e.g panintelligence.yourcompany.com

Choose a domain name for the private networking. This doesn't need verification
e.g. panintelligence.yourcompany.local

Run:
terraform init
terraform plan
terraform apply
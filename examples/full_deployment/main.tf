locals {
  dashboard_public_domain  = "dashboard.${var.domain_name}"
  dasboard_private_domain  = "dashboard.${var.private_domain_name}"
  pirana_private_domain    = "pirana.${var.private_domain_name}"
  renderer_private_domain  = "renderer.${var.private_domain_name}"
  scheduler_private_domain = "scheduler.${var.private_domain_name}"
  docker_secret_arn        = "arn:aws:secretsmanager:eu-west-1:624901044796:secret:ghcr-EqnEo4"
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "panintelligence-vpc"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
    Deployment = "panintelligence"
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = "*.${var.domain_name}"
  zone_id     = data.aws_route53_zone.this.id
}


module "public_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name    = "panintelligence-public"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }


  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = module.acm.acm_certificate_arn
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Something went wrong"
        status_code  = "200"
      }
    }
  }

  route53_records = {
    A = {
      name    = "dashboard"
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }

 }
  tags = {
    Terraform = "true"
    Environment = "dev"
    Deployment = "panintelligence"
  }
}

resource "aws_route53_zone" "local" {
  name = var.private_domain_name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

module "private_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.11.0"

  name    = "panintelligence-private"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # Security Group
  security_group_ingress_rules = {
    all_local = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }


  listeners = {
    http = {
      port            = 80
      protocol        = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Something went wrong"
        status_code  = "200"
      }
    }
  }

  route53_records = {
    A = {
      name    = "dashboard"
      type    = "A"
      zone_id = aws_route53_zone.local.zone_id
    }

 }
  tags = {
    Terraform = "true"
    Environment = "dev"
    Deployment = "panintelligence"
  }
}

module "rds-aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"
  version = "9.11.0"

  name = "panintelligence"
  engine = "aurora-mysql"
  engine_version = "8.0"

  master_username = "panintelligence"

  instances = {
    1 = {
      instance_class = "db.t3.medium"
      publicly_accessible = true
    }
  }

  vpc_id = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name


  apply_immediately   = true
  skip_final_snapshot = true

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "panintelligence-db-parameter"
  db_cluster_parameter_group_family      = "aurora-mysql8.0"
  db_cluster_parameter_group_description = "panintelligence example cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "lower_case_table_names"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "sql_mode"
      value        = "NO_AUTO_VALUE_ON_ZERO"
      apply_method = "pending-reboot"
    }
   ]

  tags = {
    Terraform = "true"
    Environment = "dev"
    Deployment = "panintelligence"
  }
}



module "pi" {
  source = "../../"
  application_subnet_ids = module.vpc.private_subnets
  dashboard_alb_listener_external_arn = module.public_alb.listeners["https"].arn
  dashboard_alb_listener_internal_arn = module.private_alb.listeners["http"].arn
  dashboard_private_domain = local.dasboard_private_domain
  dashboard_public_domain = local.dashboard_public_domain
  dashboard_task_env_vars = {
    PI_EXTERNAL_DB = "true"
    PI_TOMCAT_MAX_MEMORY = "1024"
    PI_LICENCE = var.licence
    PI_TOMCAT_COOKIE_SECURE = "true"
    PI_TOMCAT_COOKIE_SAMESITE = "none"
    RENDERER_DASHBOARD_URL = local.dasboard_private_domain


  }
  database_env_vars = {
    PI_DB_HOST = module.rds-aurora.cluster_endpoint
    #TODO: CHANGE TO FROM SECRET
    PI_DB_PASSWORD = "[4cyrSbJ$GoVOUV3:y<81(uP8Cyt"
    PI_DB_PORT = module.rds-aurora.cluster_port
    PI_DB_SCHEMA_NAME = "dashboard"
    PI_DB_USERNAME = module.rds-aurora.cluster_master_username
  }
  docker_hub_secrets_arn = local.docker_secret_arn
  private_alb_sg_id      = module.private_alb.security_group_id
  public_alb_sg_id       = module.public_alb.security_group_id
}
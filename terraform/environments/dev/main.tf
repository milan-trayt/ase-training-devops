module "github_oidc" {
  source = "../../modules/services/iam/oidc"

  stage   = var.stage
  project = var.project
  module  = var.module

  provider_url   = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

module "waf" {
  source = "../../modules/workflows/waf/cloudfront"

  stage   = var.stage
  project = var.project
  module  = var.module
}

module "cloudfront_logs_bucket" {
  source                    = "../../modules/services/s3/bucket"
  acl_enabled               = true
  force_destroy             = var.logs_bucket_force_destroy
  replication_configuration = var.logs_bucket_replication_configuration
  versioning                = var.logs_bucket_versioning
  bucket_name               = var.logs_bucket_name
  lifecycle_rules = [
    {
      days          = 90,
      storage_class = "STANDARD_IA"
    },
    {
      days          = 180,
      storage_class = "GLACIER"
    }
  ]

  tags = {
    Name        = "milan-splittr-cloudfront-logs-s3"
    Exposure    = "Private"
    Description = "Bucket for storing aws cloudfront logs"
  }
}
module "web_portal" {
  source = "../../modules/workflows/web_portal"

  stage              = var.stage
  project            = var.project
  module             = var.module
  portal_name        = var.portal_name
  portal_bucket_name = var.portal_bucket_name

  oidc_provider_arn             = module.github_oidc.arn
  waf_arn                       = module.waf.arn
  portal_access_log_bucket_name = module.cloudfront_logs_bucket.bucket_name

  portal_bucket_replication = var.portal_bucket_replication
  geo_restriction_type      = var.geo_restriction_type
  geo_restriction_location  = var.geo_restriction_location

  enforce_csp             = var.enforce_csp
  content_security_policy = var.content_security_policy
}

module "vpc" {
  source = "../../modules/services/vpc"

  stage   = var.stage
  project = var.project
  module  = var.module

  cidr = var.cidr
}

module "security_group" {
  source = "../../modules/workflows/securitygroups"

  stage   = var.stage
  project = var.project
  module  = var.module

  vpc_id        = module.vpc.vpc_id
  database_port = var.database_port
}

module "rds_aurora" {
  source                      = "../../modules/workflows/aurora_postgres"
  stage                       = var.stage
  project                     = var.project
  module                      = var.module
  instance_class              = "db.serverless"
  secret_recovery_window_days = 0
  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 2
  }
  instances = {
    postgres1 = {}
  }
  database_name                     = "devmilan"
  master_username                   = "milan"
  engine_version                    = var.engine_version
  db_cluster_parameter_group_family = "aurora-postgresql16"
  allow_major_version_upgrade       = true
  database_port                     = var.database_port
  vpc_id                            = module.vpc.vpc_id
  private_subnet_cidr               = module.vpc.private_subnet_cidr
  private_database_subnet_ids       = module.vpc.private_database_subnet_ids
  security_group_ids                = [module.security_group.sg_postgres]
}

module "api" {
  source = "../../modules/workflows/api_ecs"

  stage         = var.stage
  project       = var.project
  module        = var.module
  domain_prefix = var.stage

  ec2_image_id  = var.ec2_image_id

  oidc_provider_arn = module.github_oidc.arn

  api_security_grp_ids       = [module.security_group.sg_api]
  vpc_id                     = module.vpc.vpc_id
  api_subnet_ids             = module.vpc.private_subnet
  lb_subnet_ids              = module.vpc.public_subnet
  lb_security_grp_ids        = [module.security_group.sg_alb]
  elb_logs_bucket_versioning = "Suspended"
  ssh_public_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDID9p1M6f05M18JAs8h4FlYRKTc9qdMskTnQUfmIX1bGTtLXNLsuRk25LGeodvP3H9Xfx9n/3ggT/PWfIlRL/3Kawv8p7ntaPZcirjo1RVbUQXMPnSi+pDZZgkxFxB+Z7o5OdzOnE78Pdt73Hmw62w4yb4rjxTs8J2/tQCYoS4nz+JstqkUIbFT2wmzL5qiXDrQG9y1EzJlRFFOVDd3kj2CgqaGmkaS+6tr4qEGNsBz25utO+4HbT3XIkhJua4EuJpG46vqNtiKSSkE8ntDvbu979M+alEhC8TOgeAwg8MoRSjKS2wg+MgmPcpcdF/nHt3F0gdKmwlFSfFg9TrMeZtDgYP0NQGMzP1Bzh4lPiygoTBu+M6jcrdlrcgybWGix2lUsMB21iKU5QLN25Y3vcfpgTjAiC8dbh+3ijZCRuYJGx+YsFk8ZAeJhcX7Hw59JtbPo2Zv0uYf6NdQ3CfYARxgf9mn/n86a7r0+6TA6Ru9dwUWGnYyGXGh7nDZm9SpIM= leapfrog@LF-00002369"
  api_instance_type          = "t3.micro"

  api_instance_scaling_parameter = {
    asg_min_size    = "1"
    asg_max_size    = "3"
    target_capacity = 100
  }

  api_service_scaling_parameter = {
    scale_min_capacity = 1
    scale_max_capacity = 3
    desired_count      = 1
    cpu_scaling_parameters = {
      target_value       = 350,
      scale_in_cooldown  = 300,
      scale_out_cooldown = 180
    }

    memory_scaling_parameters = {
      target_value       = 250,
      scale_in_cooldown  = 300,
      scale_out_cooldown = 180
    }
  }

  rds_aurora_cluster_resource_id = module.rds_aurora.cluster_resource_id

}

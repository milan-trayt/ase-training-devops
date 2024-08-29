data "aws_caller_identity" "current_aurora" {}
data "aws_region" "current" {}


locals {
  deletion_protection                = var.deletion_protection
  instance_class                     = var.instance_class
  serverlessv2_scaling_configuration = var.instance_class == "db.serverless" ? var.serverlessv2_scaling_configuration : {}
}

module "rds-aurora" {
  source                                            = "terraform-aws-modules/rds-aurora/aws"
  version                                           = "9.4.0"
  count                                             = 1
  name                                              = join("-", [var.stage, var.project, var.module, "postgres-aurora"])
  database_name                                     = var.database_name
  engine                                            = "aurora-postgresql"
  engine_version                                    = var.engine_version
  engine_mode                                       = "provisioned"
  storage_encrypted                                 = true
  vpc_id                                            = var.vpc_id
  subnets                                           = var.private_database_subnet_ids
  create_db_subnet_group                            = true
  apply_immediately                                 = var.apply_immediately
  skip_final_snapshot                               = true
  deletion_protection                               = local.deletion_protection
  iam_database_authentication_enabled               = true
  master_username                                   = var.master_username
  manage_master_user_password                       = true
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = true
  master_user_password_rotation_schedule_expression = var.master_user_password_rotation_schedule_expression
  master_user_password_rotation_duration            = var.master_user_password_rotation_duration
  instance_class                                    = local.instance_class
  allow_major_version_upgrade                       = var.allow_major_version_upgrade
  create_security_group                             = length(var.security_group_ids) > 0 ? false : true
  vpc_security_group_ids                            = var.security_group_ids
  create_cloudwatch_log_group                       = true
  enabled_cloudwatch_logs_exports                   = var.enabled_cloudwatch_logs_exports
  cloudwatch_log_group_retention_in_days            = var.cloudwatch_log_group_retention_in_days
  # windows are in UTC
  preferred_backup_window      = var.preferred_backup_window
  backup_retention_period      = var.backup_retention_period
  preferred_maintenance_window = "sun:06:00-sun:07:00"
  port                         = var.database_port
  enable_http_endpoint         = true
  iam_roles                    = var.iam_roles

  instances = var.instances

  # Enhanced Monitoring
  create_monitoring_role = var.enable_enhanced_monitoring
  monitoring_interval    = var.enhanced_monitoring_interval

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = join("-", [var.stage, var.project, var.module, "aurora-db-cluster-parameter-group"])
  db_cluster_parameter_group_family      = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_description = "cluster-level postgres parameter group for ${var.stage}"
  db_cluster_parameter_group_parameters = [
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pg_stat_statements, pgaudit"
      apply_method = "pending-reboot"
    },
    {
      name         = "pgaudit.role"
      value        = "rds_pgaudit"
      apply_method = "pending-reboot"
    },
    {
      name         = "pgaudit.log"
      value        = var.audit_logs
      apply_method = "pending-reboot"
    },
    {
      name         = "pgaudit.log_level"
      value        = "log"
      apply_method = "pending-reboot"
    }
  ]

  serverlessv2_scaling_configuration = local.serverlessv2_scaling_configuration
}

data "aws_iam_policy_document" "aurora_auth" {
  statement {
    actions = [
      "rds-db:connect"
    ]
    resources = [
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current_aurora.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/readonly_user",
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current_aurora.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/application_user",
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current_aurora.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/sqlmigration_user"
    ]
  }
}

resource "aws_iam_role" "aurora_auth" {
  name = join("-", [var.stage, var.project, var.module, "database-user"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "aurora_auth" {
  name   = join("-", [var.stage, var.project, var.module, "aurora-auth-iam-policy"])
  policy = data.aws_iam_policy_document.aurora_auth.json
}

resource "aws_iam_role_policy_attachment" "aurora_auth" {
  count      = 1
  policy_arn = aws_iam_policy.aurora_auth.arn
  role       = aws_iam_role.aurora_auth.name
}

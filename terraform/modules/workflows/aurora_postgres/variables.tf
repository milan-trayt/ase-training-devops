variable "stage" {
  type        = string
  description = "Environment the portal belongs to. eg. dev, qa etc."
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "module" {
  type        = string
  description = "Module name of the project"
}

variable "enhanced_monitoring_interval" {
  type    = number
  default = 0
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "instance_class" {
  type    = string
  default = "db.serverless"
}

variable "secret_recovery_window_days" {
  type    = number
  default = 0
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "private_database_subnet_ids" {
  type        = list(string)
  description = "List of private subnet ids for database"
}

variable "database_name" {
  type = string
}

variable "master_username" {
  type = string
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "engine_version" {
  type        = string
  description = "Database Engine Version"
}

variable "allow_major_version_upgrade" {
  type        = bool
  default     = false
  description = "Enable/Disable major version upgrade. This does not automatically upgrade the major version"
}

variable "db_cluster_parameter_group_family" {
  type        = string
  description = "Parameter group family"
}

variable "database_port" {
  type        = number
  default     = 5432
  description = "Database port"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security group ids"
}

variable "instances" {
  type        = map(any)
  description = "Instances to be created"
}

variable "iam_roles" {
  description = "Map of IAM roles and supported feature names to associate with the cluster"
  type        = map(map(string))
  default     = {}
}

variable "serverlessv2_scaling_configuration" {
  type = map(any)
  default = {
    min_capacity = 0.5
    max_capacity = 2
  }
  description = "serverless scaling min and max capacity"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = ["postgresql"]
  description = "Set of log types to export to cloudwatch"
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  default     = 1
  description = "The number of days to retain CloudWatch logs for the DB instance"
}

variable "master_user_password_rotation_duration" {
  type        = string
  default     = null
  description = "The length of the rotation window in hours"
}

variable "master_user_password_rotation_schedule_expression" {
  type        = string
  default     = "rate(1 days)"
  description = "A cron() or rate() expression that defines the schedule for rotating your secret"
}

variable "audit_logs" {
  type        = string
  default     = "none"
  description = "audit logs to enable ddl,function,misc,read,role,write,none,all,-ddl,-function,-misc,-read,-role,-write"
}

variable "backup_retention_period" {
  type        = number
  default     = null
  description = "number of days to retain automated backups"
}

variable "preferred_backup_window" {
  type        = string
  default     = null
  description = "preferred backup window duration for automated backups"
}

variable "enable_enhanced_monitoring" {
  type        = bool
  default     = false
  description = "Enable enhanced monitoring"
}

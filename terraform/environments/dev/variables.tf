variable "stage" {
  type        = string
  default     = "dev"
  description = "Environment the portal belongs to. eg. dev, qa etc."
}

variable "project" {
  type        = string
  default     = "milan"
  description = "Name of the project"
}

variable "module" {
  type        = string
  default     = "splittr"
  description = "Module name of the project"
}

###################################
# Cloudfront Log Bucket Variables #
###################################
variable "logs_bucket_force_destroy" {
  type        = bool
  default     = false
  description = "Force destroy the bucket"
}

variable "logs_bucket_replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = {}
}

variable "logs_bucket_versioning" {
  type        = string
  default     = "Suspended"
  description = "Enable/Disable bucket versioning"
}

variable "logs_bucket_name" {
  type        = string
  default     = "milan-splittr-cloudfront-logs-s3"
  description = "Name of the bucket where cloudfront logs are stored"
}

########################
# Web Portal Variables #
########################

variable "portal_name" {
  type        = string
  default     = "web"
  description = "Name of the web portal."
}

variable "portal_bucket_name" {
  type        = string
  default     = "milan-splittr-web-portal"
  description = "Name of the bucket where web portal's build is stored"
}

variable "portal_bucket_replication" {
  type        = bool
  default     = false
  description = "Enable/Disable web portal's bucket replication"
}

variable "geo_restriction_type" {
  type        = string
  default     = "none"
  description = "Geo restriction type for the web portal"
}

variable "geo_restriction_location" {
  type        = list(string)
  default     = []
  description = "Geo restriction location for the web portal"
}

variable "enforce_csp" {
  type        = bool
  default     = false
  description = "Enable/Disable Content Security Policy"
}

variable "content_security_policy" {
  type        = map(string)
  default     = {}
  description = "Content Security Policy for the web portal"
}

#################
# VPC Variables #
#################

variable "cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR block for the VPC"
}

############################
# Security Group Variables #
############################

variable "database_port" {
  type        = number
  default     = 5432
  description = "Port for the database"
}

########################
# Aurora RDS Variables #
########################

variable "engine_version" {
  type        = string
  default     = "16.1"
  description = "Engine version for the Aurora RDS"
}

#################
# ECS Variables #
#################

variable "ec2_image_id" {
  type        = string
  description = "AMI ID for the ECS cluster"
  default     = "ami-066784287e358dad1"
}

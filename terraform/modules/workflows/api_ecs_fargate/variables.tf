variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "api_security_grp_ids" {
  type        = list(string)
  description = "Security group for the API service in ECS Fargate"
}

variable "lb_security_grp_ids" {
  type        = list(string)
  description = "List of security groups for load balancer"
}

variable "lb_subnet_id" {
  type        = list(string)
  description = "List of subnet for load balancer"
}

variable "api_subnet_id" {
  type        = list(string)
  description = "List of subnet for api"
}

variable "stage" {
  type        = string
  description = "Stage of the project"
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "module" {
  type        = string
  description = "Module name of the project"
}

variable "api_secret_replica_region" {
  type        = list(string)
  default     = []
  description = "Region to replicate the api secrets to"
}

variable "api_secret_arn" {
  type        = string
  description = "API secret ARN"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN"
}

variable "ecr_repos_arn" {
  type        = list(string)
  description = "ECR repository ARN"
}

variable "rds_aurora_cluster_resource_id" {
  type        = string
  description = "RDS Aurora cluster resource ID"
}

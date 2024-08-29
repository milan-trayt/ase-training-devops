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

variable "domain_prefix" {
  type        = string
  description = "Domain prefix name of the project"
}

variable "elb_logs_bucket_versioning" {
  type        = string
  default     = "Enabled"
  description = "Enable/Disable versioning in alb logs bucket"
}

variable "lb_subnet_ids" {
  type        = list(string)
  description = "List of subnet for load balancer"
}

variable "lb_security_grp_ids" {
  type        = list(string)
  description = "List of security groups for load balancer"
}

variable "api_secret_replica_region" {
  type        = list(string)
  default     = []
  description = "Region to replicate the api secrets to"
}

variable "ami" {
  type        = string
  description = "Ec2 AMI"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for ECS cluster instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "api_security_grp_ids" {
  type        = list(string)
  description = "Security group for the API service"
}

variable "api_subnet_ids" {
  type        = list(string)
  description = "Subnet where the API server will be placed"
}

variable "api_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for APi service"
}

variable "api_instance_scaling_parameter" {
  type = map(any)
  default = {
    asg_min_size    = "0"
    asg_max_size    = "3"
    target_capacity = 100
  }
  description = "Scaling parameter for API autoscaling group. This is used for Ec2 instance scaling"
}

variable "api_service_scaling_parameter" {
  type = object({
    scale_min_capacity        = number
    scale_max_capacity        = number
    desired_count             = number
    cpu_scaling_parameters    = map(any)
    memory_scaling_parameters = map(any)
  })
  default = {
    scale_min_capacity = 0
    scale_max_capacity = 3
    desired_count      = 0
    cpu_scaling_parameters = {
      cpu_allocated      = 2048
      target_value       = 350,
      scale_in_cooldown  = 300,
      scale_out_cooldown = 180
    }

    memory_scaling_parameters = {
      memory_allocated   = 4096
      target_value       = 250,
      scale_in_cooldown  = 300,
      scale_out_cooldown = 180
    }
  }
  description = "Scaling parameter for API autoscaling group. This is used for Ec2 instance scaling"
}

variable "api_s3_buckets_arn" {
  type        = list(string)
  default     = []
  description = "List of s3 buckets api has access to"
}

variable "api_replica_s3_buckets_arn" {
  type        = list(string)
  default     = []
  description = "List of replica s3 buckets api has access to"
}

variable "rds_aurora_cluster_resource_id" {
  type        = string
  description = "Aurora cluster resource id"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN for oidc provider"
}

variable "api_secret_arn" {
  type        = string
  description = "ARN for API secret"
  default     = null
}

variable "ecr_repos_arn" {
  type        = list(string)
  description = "List of additional ECR repositories"
  default     = []
}

variable "task_policies" {
  type        = list(string)
  default     = []
  description = "List of additional policy documents to attach to the ECS task role"
}

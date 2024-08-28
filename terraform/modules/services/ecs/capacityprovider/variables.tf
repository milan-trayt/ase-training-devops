variable "name" {
  type        = string
  description = "Capacity provider name"
}

variable "ec2_hostname" {
  type        = string
  description = "Ec2 instance hostname"
}

variable "ami_owners" {
  type        = list(string)
  description = "List of owners to search the AMI in"
}

variable "ami_filter_name" {
  type        = list(string)
  description = "value of the name filter to search the AMI"
}

variable "cluster_name" {
  type        = string
  description = "Name of ECS cluster to associate the Ec2 instance with"
}

variable "maximum_scaling_step_size" {
  type        = number
  default     = 1
  description = "Maximum step adjustment size. A number between 1 and 10,000."
}

variable "minimum_scaling_step_size" {
  type        = number
  default     = 1
  description = "Minimum step adjustment size. A number between 1 and 10,000."
}

variable "target_capacity" {
  type        = number
  default     = 4
  description = "Target utilization for the capacity provider. A number between 1 and 100."
}

variable "instance_warmup_period" {
  type        = number
  default     = 60
  description = "Period of time, in seconds, after a newly launched Amazon EC2 instance can contribute to CloudWatch metrics for Auto Scaling group"
}

variable "asg_max_size" {
  type        = number
  default     = 1
  description = "Maximum size of the Auto Scaling Group"
}

variable "asg_min_size" {
  type        = number
  default     = 1
  description = "Maximum size of the Auto Scaling Group"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Instance type for Ec2 launch type"
}

variable "ec2_image_id" {
  type        = string
  default     = null
  description = "The EC2 image ID to launch."
}

variable "ec2_key_name" {
  type        = string
  default     = null
  description = "The key name that should be used for the instance."
}

variable "managed_termination_protection" {
  type        = string
  default     = "DISABLED"
  description = "Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "List of subnets to deploy service on."
}

variable "security_grp_ids" {
  type        = list(string)
  default     = []
  description = "List of security groups to assign for the service."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "VPC ID to deploy the ECS on."
}

variable "user_data" {
  type        = string
  default     = null
  description = "Ec2 instance startup script"
}

variable "kms_key_arn" {
  type        = string
  description = "AWS Kms key id to encrypt EBS volume"
  default     = null
}

variable "tags" {
  type = map(any)
}

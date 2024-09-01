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

variable "subnet_id" {
  type        = list(string)
  description = "List of subnet for load balancer"
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
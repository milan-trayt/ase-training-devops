variable "name" {
  type        = string
  description = "Repo name"
}

variable "region" {
  description = "Deployed Region"
  type        = string
}

variable "aws_ecs_cluster_id" {
  type        = string
  description = "ECS Cluster ID to run service on."
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster ID to run service on."
}

variable "task_role_arn" {
  type        = string
  description = "iam role arn for ecs task"
}

variable "launch_type" {
  type        = string
  default     = "EC2"
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE"
}

variable "log_retention_days" {
  type        = number
  default     = 1
  description = "Days to keep ecs logs."
}

variable "ecr_repos_arn" {
  type        = list(string)
  description = "ecr repo arn"
}

variable "container_port" {
  type        = number
  default     = 443
  description = "Port in container where application is deployed"
}

variable "health_check_path" {
  type        = string
  description = "Health check endpoint for ALB"
  default     = "/health/getTime"
}

variable "capacity_provider_strategy" {
  type        = list(any)
  default     = []
  description = "List of capacity provider strategy for service"
}

variable "placement_constraints_type" {
  type        = string
  default     = "distinctInstance"
  description = "Type of placement constraint"
}

variable "force_new_deployment" {
  type    = bool
  default = null
}

variable "cpu" {
  type        = string
  description = "Size of vCPU to allocate. 0.5 = 512"
  default     = null
}

variable "memory" {
  type        = string
  description = "Size of RAM to allocate in MB"
  default     = null
}

variable "desired_count" {
  type        = number
  description = "Number of task to deploy for a service."
  default     = 1
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets to deploy service on."
}

variable "security_grp_ids" {
  type        = list(string)
  description = "List of security groups to assign for the service."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy the ecs on."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Should the ecs task instance assigned public IP."
}

variable "scale_min_capacity" {
  type        = number
  description = "Maximum number of instances to run for a service."
  default     = 1
}

variable "scale_max_capacity" {
  type        = number
  description = "Maximum number of instances to run for a service."
  default     = 1
}

variable "cpu_scaling_parameters" {
  type = object({ target_value = number, scale_in_cooldown = number, scale_out_cooldown = number })

  default = {
    target_value       = 0,
    scale_in_cooldown  = 0,
    scale_out_cooldown = 0
  }

  description = "Scaling parameters based on cpu metrics"
}

variable "memory_scaling_parameters" {
  type = object({ target_value = number, scale_in_cooldown = number, scale_out_cooldown = number })

  default = {
    target_value       = 0,
    scale_in_cooldown  = 0,
    scale_out_cooldown = 0
  }

  description = "Scaling parameters based on memory metrics"
}

variable "service_domain_name" {
  type        = list(string)
  default     = ["*.*"]
  description = "Domain name for the service hosted on the cluster."
}

variable "service_path" {
  type        = list(string)
  default     = ["/", "/*"]
  description = "path at which the service is serving. eg. /login"
}

variable "task_volumes" {
  type        = list(any)
  default     = []
  description = "Volumes to use with the Ecs service"
}

variable "alb_listener_arn" {
  type        = string
  default     = null
  description = "listener arn for loadbalancer to attach target group to"
}

variable "container_definitions" {
  type        = string
  description = "Json file containing the container definition"
}

variable "deployment_controller" {
  type        = string
  default     = "CODE_DEPLOY"
  description = "Deployment controller for ECS service"
}

variable "deployment_option" {
  type        = string
  default     = "WITH_TRAFFIC_CONTROL"
  description = "whether to route deployment traffic behind a load balancer"
}

variable "deployment_type" {
  type        = string
  default     = "BLUE_GREEN"
  description = "whether to run an in-place deployment or a blue/green deployment"
}

variable "container_name" {
  type        = string
  default     = "nginx"
  description = "Default container to expose to the loadbalancer in ECS"
}

variable "alb_name" {
  type        = string
  default     = null
  description = "Name of application loadbalancer associated with the service"
}

variable "load_balancing_algorithm_type" {
  type        = string
  default     = "least_outstanding_requests"
  description = "Determines how the load balancer selects targets when routing requests."
}

variable "network_mode" {
  type        = string
  default     = "bridge"
  description = "Network mode for service. eg. bridge or awsvpc"
}

variable "vpc_network_configuration" {
  type        = list(any)
  default     = []
  description = "Network configuration for awsvpc network mode"
}

variable "tags" {
  type = map(any)
}

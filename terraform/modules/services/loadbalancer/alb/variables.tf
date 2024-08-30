variable "name" {
  type        = string
  description = "Alb Name"
}

variable "internal_loadbalancer" {
  type    = bool
  default = false
}

variable "elb_logs_bucket_versioning" {
  type        = string
  default     = "Suspended"
  description = "Enable/Disable bucket versioning for ALB logs bucket"
}

variable "lb_subnet_ids" {
  type        = list(string)
  description = "List of subnets to deploy load balancer on."
}

variable "lb_security_grp_ids" {
  type        = list(string)
  description = "List of security groups to assign for the load balancer."
}

variable "listener_rules" {
  type        = list(object({ target_group_arn = string, action = string, host_header = list(string), path_pattern = list(string) }))
  default     = []
  description = "listener rule to attach to the loadbalancer"
}

variable "tags" {
  type = map(any)
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  description = "AWS managed SSL policy for the listener"
}

variable "alb_deletion_protection" {
  type        = bool
  default     = false
  description = "Enable/Disable deletion protection for ALB"
}
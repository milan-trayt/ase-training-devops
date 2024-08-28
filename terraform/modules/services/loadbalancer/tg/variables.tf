variable "name" {
  type        = string
  description = "name of the target group"
}

variable "port" {
  type        = number
  description = "port for the app listener"
}

variable "vpc_id" {
  type        = string
  description = "vpc id for the target group"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "endpoint to check app health"
}

variable "protocol" {
  type        = string
  default     = "HTTP"
  description = "protocol to access the target. HTTP or HTTPS"
}

variable "target_type" {
  type        = string
  default     = "instance"
  description = "type of target registered in the target group. lambda, ip or instance"
}

variable "tags" {
  type        = map(any)
  description = "tags"
}

variable "name" {
  type        = string
  description = "Cluster Name"
}

variable "launch_type" {
  type        = string
  default     = "EC2"
  description = "Launch type on which to run your service. The valid values are EC2, FARGATE"
}

variable "capacity_providers" {
  type        = list(string)
  description = "List of capacity providers for the cluster"
}

variable "tags" {
  type = map(any)
}

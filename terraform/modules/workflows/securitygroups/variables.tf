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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC the security groups should belong to"
}

variable "database_port" {
  type    = number
  default = 5432
}

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
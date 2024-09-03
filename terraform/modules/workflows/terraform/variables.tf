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

variable "repo_name" {
  type        = string
  default     = null
  description = "Repo the portal belongs to. eg. terrafrom-code  etc."
}

variable "oidc_name" {
  type        = string
  default     = "token.actions.githubusercontent.com"
  description = "Repo the portal belongs to. eg. terrafrom-code  etc."
}

variable "oidc_provider_arn" {
  type        = string
  default     = null
  description = "Repo the portal belongs to. eg. terrafrom-code  etc."
}
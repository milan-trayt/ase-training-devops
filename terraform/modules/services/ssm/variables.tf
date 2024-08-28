variable "name" {
  type        = string
  description = "ssm parameter name"
}

variable "value" {
  type        = string
  description = "ssm parameter value"
}

variable "tags" {
  type = map(any)
}

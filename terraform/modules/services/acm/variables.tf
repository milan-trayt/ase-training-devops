variable "domain_name" {
  type = string
}

variable "domain_alternative_names" {
  type        = set(string)
  default     = []
  description = "alternative domain names to associate with the certificate"
}

variable "tags" {
  type = map(any)
}

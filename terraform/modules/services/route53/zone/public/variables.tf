variable "primary_domain_name" {
  type        = string
  description = "primary domain name for the hosted zone"
}

variable "tags" {
  type = map(string)
}


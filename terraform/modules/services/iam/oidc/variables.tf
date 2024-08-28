variable "provider_url" {
  type        = string
  default     = "https://token.actions.githubusercontent.com"
  description = "The URL of the identity provider. Corresponds to the iss claim."
}

variable "client_id_list" {
  type        = list(string)
  default     = ["sts.amazonaws.com"]
  description = "A list of client IDs (also known as audiences). When a mobile or web app registers with an OpenID Connect provider, they establish a value that identifies the application."
}

variable "thumbprint_list" {
  type        = list(string)
  default     = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  description = "A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)."
}

variable "stage" {
  type        = string
  description = "Environment the resource belongs to. eg. dev, qa etc."
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "module" {
  type        = string
  description = "Module name of the project"
}
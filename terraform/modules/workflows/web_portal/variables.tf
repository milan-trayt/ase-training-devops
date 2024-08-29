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

variable "portal_name" {
  type        = string
  description = "Name of the web portal. eg. clinician, access etc."
}

variable "portal_domain_aliases" {
  type        = list(string)
  default     = []
  description = "List of domain names aliases for the web portal"
}

variable "portal_bucket_name" {
  type        = string
  description = "Name of the bucket where web portal's build is stored"
}
variable "portal_bucket_versioning" {
  type        = string
  default     = "Suspended"
  description = "Enable/Disable bucket versioning for web portal's s3 bucket"
}

variable "portal_bucket_replication" {
  type        = bool
  default     = false
  description = "Enable/Disable web portal's bucket replication"
}

variable "portal_replica_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for bucket replica"
}

variable "portal_redirect_url" {
  type        = string
  default     = null
  description = "Hostname to which the web portal should be redirected"
}

variable "oidc_provider_arn" {
  type        = string
  description = "Arn of GitHub OIDC provider"
}

variable "waf_arn" {
  type        = string
  description = "ARN for the WAF to associate the web portal with"
}

variable "feature_portal" {
  type        = bool
  default     = false
  description = "Whether the portal is being created for feature environment."
}

variable "portal_access_log_bucket_name" {
  type        = string
  description = "Name of s3 bucket for storing portal access logs"
}

variable "geo_restriction_type" {
  type        = string
  default     = "none"
  description = "Whether the portal whould be allowed or denied access from specified locations"
}
variable "geo_restriction_location" {
  type        = list(string)
  default     = []
  description = "List of regions where the portal should be denied/granted access from"
}

variable "index_file_server" {
  type        = bool
  default     = false
  description = "Create a index file server function"
}

variable "portal_repo" {
  type        = string
  default     = null
  description = "Repo the portal belongs to. eg. access-portal, school-portal etc."
}

variable "pr_repos" {
  type        = list(string)
  default     = []
  description = "List of repos to grant access for Pull request portal"
}

variable "disable_public_bucket" {
  type        = bool
  default     = true
  description = "If the public access to bucket should be disabled. Default true"
}

variable "content_security_policy" {
  type = map(string)
}

variable "enforce_csp" {
  type        = bool
  default     = false
  description = "Enforce content security policy"
}

variable "secret_replica_region" {
  type        = list(string)
  default     = []
  description = "Regions to replicate the portal secret in"
}
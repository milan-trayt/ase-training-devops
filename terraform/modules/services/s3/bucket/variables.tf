variable "bucket_name" {
  type        = string
  description = "Name of S3 bucket to create"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "ID of Key in KMS to use for encryption"
}

variable "sse_algorithm" {
  type    = string
  default = "AES256"
}

variable "acl_enabled" {
  type        = bool
  default     = false
  description = "Enable Bucket ACL"
}

variable "versioning" {
  type        = string
  default     = "Suspended"
  description = "enable or suspend object versioning"
}

variable "mfa_delete" {
  type        = bool
  default     = false
  description = "enable or disable mfa delete"
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = "Destroy the bucket forcefully(deleting the objects inside)"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "block access management via public bucket policy"
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "block access to objects with acls"
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "block access to objects with acls"
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "block access to objects with acls"
}

variable "index_document" {
  type        = string
  default     = "index.html"
  description = "if static hosting. name of index document"
}

variable "error_document" {
  type        = string
  default     = "error.html"
  description = "if static hosting. name of error document"
}

variable "replication_configuration" {
  description = "Map containing cross-region replication configuration."
  type        = any
  default     = {}
}

variable "sse_kms_encrypted_objects" {
  description = "filter information for the selection of Amazon S3 objects encrypted with AWS KMS"
  type        = string
  default     = "Enabled"
}

variable "replica_kms_key_id" {
  description = "The ID (Key ARN or Alias ARN) of the customer managed AWS KMS key stored in AWS Key Management Service (KMS) for the destination bucket."
  type        = string
  default     = null
}

variable "replica_region" {
  description = "Name of the AWS region for replica bucket"
  type        = string
  default     = "us-east-1"

}

variable "tags" {
  type = map(any)
}

variable "server_access_log_bucket" {
  type        = string
  default     = null
  description = "Prefix for all log object keys"
}

variable "enable_bucket_access_logging" {
  type    = bool
  default = false
  # validation {
  #   condition     = var.server_access_log_bucket != null
  #   error_message = "The target access log bucket name cannot be empty"
  # }
  description = "Flag to enable/disable server access logging. Server_access_log_bucket cannot empty"
}

variable "bucket_policy" {
  type        = string
  default     = null
  description = "Bucket policy"
}

variable "replica_bucket_policy" {
  type        = string
  default     = null
  description = "Replica bucket policy"
}

variable "lifecycle_rules" {
  type = list(object({
    days          = number
    storage_class = string
  }))
  default     = []
  description = "List of lifecycle lifecycle rules for Transition from one storage class to another"
}
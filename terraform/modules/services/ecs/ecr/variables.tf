variable "name" {
  type        = string
  description = "ECR Registry name"
}

variable "encryption_type" {
  type        = string
  default     = "AES256"
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS"
}

variable "kms_key" {
  type        = string
  default     = null
  description = "The ARN of the KMS key to use when encryption_type is KMS"
}

variable "tags" {
  type = map(any)
}

variable "name" {
  type = string
}
variable "description" {
  type = string
}

variable "deletion_window_in_days" {
  type    = number
  default = 7
}

variable "key_alias" {
  type        = string
  description = "alias name for the key. eg. dev"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
}

variable "policy" {
  type        = string
  default     = null
  description = "A valid policy JSON document"
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region"
}

variable "tags" {
  type = map(any)
}

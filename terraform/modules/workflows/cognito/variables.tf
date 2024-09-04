variable "user_pool_name" {
  type        = string
  description = "Name of the user pool"
}

variable "username_attributes" {
  type        = list(string)
  description = "Attributes that are auto-verified"
}

variable "email_sending_account" {
  type        = string
  description = "Email sending account"
}

variable "deletion_protection" {
  type        = bool
  description = "Enable/Disable deletion protection"
}
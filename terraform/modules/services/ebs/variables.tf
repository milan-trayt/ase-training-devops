variable "size" {
  type = number
}

variable "availability_zone" {
  type = string
}

variable "encrypted" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  type = string
}

variable "tags" {
  type = map(any)
}

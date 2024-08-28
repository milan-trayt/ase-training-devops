variable "ami" {
  type = string
}
variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_instance_name" {
  type = string
}

variable "ssh_key_id" {
  type = string
}

variable "ec2_volume_size" {
  type = number
}

variable "user_data" {
  type    = string
  default = null
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_target_port" {
  type    = number
  default = 80
}

variable "target_group_target_protocol" {
  type    = string
  default = "HTTP"
}

variable "enable_elastic_ip" {
  type    = bool
  default = false
}

variable "enable_public_ip" {
  type    = bool
  default = true
}

variable "encrypt_root_volume" {
  type    = bool
  default = true
}

variable "delete_volume_on_termination" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  type = string
}

variable "enable_target_group" {
  type        = bool
  default     = false
  description = "Whether to create a target group and register this instance to that target group or not?"
}

variable "iam_instance_profile" {
  type        = string
  default     = null
  description = "Iam role profile for ec2"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "health check path for the instance if registered with a target group"
}

variable "backup_count" {
  type        = number
  default     = 0
  description = "Daily backups to retain through lifecycle policy. set 0 for none"
}

variable "backup_regions" {
  type        = list(string)
  default     = []
  description = "List of regions to backup the instance to"
}

variable "tags" {
  type = map(string)
}

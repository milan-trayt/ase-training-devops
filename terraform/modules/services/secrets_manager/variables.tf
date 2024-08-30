variable "name" {
  type        = string
  description = "Friendly name of the new secret"
}

variable "recovery_window_in_days" {
  type        = number
  default     = 0
  description = "Number of days to retain secret after deletion"
}

variable "replica_region" {
  type        = list(string)
  default     = []
  description = "Region for replicating the secret"
}

variable "tags" {
  type        = map(any)
  description = "tags for resource"
}

variable "bucket_id" {
  type        = string
  description = "Name of S3 bucket"
}

variable "filename_in_s3" {
  type        = string
  description = "File name to save as in S3 bucket"
}

variable "file_source_location" {
  type        = string
  description = "Local path of file to upload in S3."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "ID of Key in KMS to use for encryption"
}

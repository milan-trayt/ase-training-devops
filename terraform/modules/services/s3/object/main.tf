resource "aws_s3_bucket_object" "default" {
  bucket = var.bucket_id
  key    = var.filename_in_s3
  source = var.file_source_location
  etag   = filemd5(var.file_source_location)
}

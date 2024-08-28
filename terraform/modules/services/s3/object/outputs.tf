output "filename" {
  value = aws_s3_bucket_object.default.key
}

output "bucket_name" {
  value = aws_s3_bucket_object.default.bucket
}

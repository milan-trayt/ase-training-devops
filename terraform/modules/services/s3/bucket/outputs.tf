output "bucket_id" {
  value = aws_s3_bucket.default.id
}

output "bucket_name" {
  value = aws_s3_bucket.default.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.default.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.default.bucket_regional_domain_name
}

output "replica_bucket_arn" {
  value = length(keys(var.replication_configuration)) > 0 ? aws_s3_bucket.replica[0].arn : "arn:aws:s3:::backup.${var.bucket_name}"
}
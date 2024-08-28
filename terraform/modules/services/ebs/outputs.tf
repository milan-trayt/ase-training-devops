output "id" {
  value = var.encrypted ? aws_ebs_volume.encrypted[0].id : aws_ebs_volume.unencrypted[0].id
}

output "arn" {
  value = var.encrypted ? aws_ebs_volume.encrypted[0].arn : aws_ebs_volume.unencrypted[0].arn
}

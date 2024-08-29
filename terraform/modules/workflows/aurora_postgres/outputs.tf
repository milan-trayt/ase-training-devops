output "cluster_resource_id" {
  value = module.rds-aurora[0].cluster_resource_id
}

output "db_connect_policy_document" {
  value = data.aws_iam_policy_document.aurora_auth.json
}

output "cluster_arn" {
  value = module.rds-aurora[0].cluster_arn
}

output "cluster_arn" {
  value = module.cluster.ecs_cluster_arn
}

output "api_task_role_arn" {
  value = aws_iam_role.api_ecs_task_role.arn
}

output "api_secret_arn" {
  value = var.api_secret_arn == null ? module.api_secrets[0].arn : var.api_secret_arn
}

output "api_secret_name" {
  value = var.api_secret_arn == null ? module.api_secrets[0].name : var.api_secret_arn
}


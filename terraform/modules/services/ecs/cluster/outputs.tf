output "ecs_cluster_id" {
  value = aws_ecs_cluster.default.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.default.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.default.arn
}

output "cluster_launch_type" {
  value = var.launch_type
}

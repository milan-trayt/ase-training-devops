output "task_definition_arn" {
  value = aws_ecs_task_definition.default.arn
}

output "service_name" {
  value = aws_ecs_service.default.name
}

output "service_arn" {
  value = aws_ecs_service.default.id
}

output "container_port" {
  value = var.container_port
}

output "target_group_name" {
  value = aws_lb_target_group.default[*].name
}

output "task_execution_role_id" {
  value = aws_iam_role.ecs_task_execution_role.id
}

output "ecs_autoscale_target" {
  value = aws_appautoscaling_target.ecs-autoscale
}

output "name" {
  value = aws_ecs_capacity_provider.this.name
}


output "ecs_ec2_role_id" {
  value = aws_iam_role.ecs_ec2_role.id
}
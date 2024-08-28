output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "target group arn"
}

output "target_group_name" {
  value = aws_lb_target_group.this.name
}

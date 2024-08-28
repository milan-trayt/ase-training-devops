
output "public_dns" {
  value = aws_instance.ec2.public_dns
}

output "public_ip" {
  value       = var.enable_elastic_ip ? aws_eip.elastic_ip[0].public_ip : aws_instance.ec2.public_ip
  description = "instance public ip."
}

output "private_ip" {
  value = aws_instance.ec2.private_ip
}

output "ec2_arn" {
  value = aws_instance.ec2.arn
}

output "target_group_arn" {
  value       = var.enable_target_group ? aws_lb_target_group.this[0].arn : ""
  description = "target group arn for ec2 if registered"
}


output "read_role_arn" {
  description = "Arn of terraform read role"
  value       = aws_iam_role.terraform_read_role.arn
}

output "write_role_arn" {
  description = "Arn of terraform write role"
  value       = aws_iam_role.terraform_write_role.arn
}

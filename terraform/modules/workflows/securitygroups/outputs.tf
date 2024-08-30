output "sg_alb" {
  value = aws_security_group.sg_alb.id
}

output "sg_api" {
  value = aws_security_group.sg_api.id
}

output "sg_postgres" {
  value = aws_security_group.sg_postgres.id
}

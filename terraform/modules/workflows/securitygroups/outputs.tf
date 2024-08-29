output "sg_alb" {
  value = aws_security_group.sg_alb.id
}

output "sg_api" {
  value = aws_security_group.sg_api.id
}

output "sg_opensearch" {
  value = aws_security_group.sg_api_opensearch.id
}

output "sg_ecr" {
  value = aws_security_group.sg_ecr_vpce.id
}

output "sg_redis" {
  value = aws_security_group.sg_redis_cluster.id
}

output "sg_lambda" {
  value = aws_security_group.sg_lambda_default.id
}

output "sg_sqsqueue" {
  value = aws_security_group.sg_sqsqueue.id
}

output "sg_postgres" {
  value = aws_security_group.sg_postgres.id
}

output "sg_workspace" {
  value = aws_security_group.sg_workspace.id
}

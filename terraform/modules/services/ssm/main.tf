resource "aws_ssm_parameter" "this" {
  name  = var.name
  type  = "SecureString"
  value = var.value

  lifecycle {
    ignore_changes = all
  }

  tags = var.tags
}

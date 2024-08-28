resource "aws_secretsmanager_secret" "this" {
  name                    = var.name
  recovery_window_in_days = var.recovery_window_in_days

  dynamic "replica" {
    for_each = var.replica_region
    content {
      region = replica.value
    }
  }

  tags = var.tags
}
data "aws_iam_policy_document" "main" {
  dynamic "statement" {
    for_each = var.permission_sets
    content {
      effect    = "Allow"
      actions   = lookup(var.permissable_actions, statement.value.action, null)
      resources = try(length(statement.value.resources), 0) > 0 ? statement.value.resources : ["*"]
    }
  }
}

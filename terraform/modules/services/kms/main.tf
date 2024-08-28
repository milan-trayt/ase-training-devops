resource "aws_kms_key" "this" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = var.policy
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.key_alias}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_ebs_volume" "encrypted" {
  count = var.encrypted ? 1 : 0

  availability_zone = var.availability_zone
  size              = var.size

  encrypted  = var.encrypted
  kms_key_id = var.kms_key_arn

  tags = var.tags
}

resource "aws_ebs_volume" "unencrypted" {
  count = var.encrypted ? 0 : 1

  availability_zone = var.availability_zone
  size              = var.size

  tags = var.tags
}

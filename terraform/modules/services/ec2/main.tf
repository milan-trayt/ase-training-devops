data "aws_region" "current" {}

resource "aws_instance" "ec2" {
  ami                         = var.ami
  instance_type               = var.ec2_instance_type
  key_name                    = var.ssh_key_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.enable_public_ip
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = var.user_data
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size           = var.ec2_volume_size
    delete_on_termination = var.delete_volume_on_termination
    encrypted             = var.encrypt_root_volume
    kms_key_id            = var.kms_key_arn

    tags = merge(
      var.tags,
      {
        Name        = "${var.ec2_instance_name}-ebs"
        Exposure    = "private"
        Description = "ebs root volume for ${var.ec2_instance_name}"
      }
    )
  }

  lifecycle {
    ignore_changes = [
      key_name,
      ami
    ]
  }


  tags = var.tags
}

resource "aws_eip" "elastic_ip" {
  count = var.enable_elastic_ip ? 1 : 0

  instance = aws_instance.ec2.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.ec2_instance_name}-eip"
      Exposure    = "public"
      Description = "elastic ip for ${var.ec2_instance_name}"
    }
  )

}

resource "aws_lb_target_group" "this" {
  count       = var.enable_target_group ? 1 : 0
  name        = "${var.ec2_instance_name}-tg"
  target_type = "instance"
  protocol    = var.target_group_target_protocol
  port        = var.target_group_target_port
  vpc_id      = var.vpc_id

  health_check {
    enabled           = true
    protocol          = var.target_group_target_protocol
    path              = var.health_check_path
    interval          = 60
    timeout           = 30
    healthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.ec2_instance_name}-targetgroup"
      Exposure    = "private"
      Description = "target group for ${var.ec2_instance_name}"
    }
  )
}

resource "aws_lb_target_group_attachment" "this" {
  count            = var.enable_target_group ? 1 : 0
  target_group_arn = aws_lb_target_group.this[0].arn
  target_id        = aws_instance.ec2.id
  port             = var.target_group_target_port
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role-${var.ec2_instance_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "dlm-lifecycle-policy-${var.ec2_instance_name}"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DeleteSnapshot",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots",
            "ec2:CopySnapshot"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

resource "aws_dlm_lifecycle_policy" "this" {
  count              = var.backup_count > 0 ? 1 : 0
  description        = "${var.ec2_instance_name} backup policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "${var.ec2_instance_name}_daily_backup"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = var.backup_count
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      dynamic "cross_region_copy_rule" {
        for_each = var.backup_regions

        content {
          target    = cross_region_copy_rule.value
          cmk_arn   = replace(var.kms_key_arn, data.aws_region.current.name, cross_region_copy_rule.value)
          encrypted = true
          copy_tags = true
          retain_rule {
            interval      = 10
            interval_unit = "DAYS"
          }
        }
      }
      copy_tags = true
    }

    target_tags = {
      Name = "${var.ec2_instance_name}-ebs"
    }
  }

  tags = var.tags
}

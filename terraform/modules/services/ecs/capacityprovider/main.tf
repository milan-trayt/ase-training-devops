locals {
  default_user_data = <<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config

datadog_config=$(aws secretsmanager get-secret-value --secret-id datadog --region us-west-2)
secret_string=$(echo "$datadog_config" | jq -r '.SecretString')
parsed_json=$(echo "$secret_string" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
echo "$parsed_json" > /etc/datadog-agent/environment
sudo systemctl restart datadog-agent
EOF
}
resource "aws_autoscaling_group" "this" {
  name                  = join("-", [var.name, "asg"])
  vpc_zone_identifier   = var.subnet_ids
  protect_from_scale_in = var.managed_termination_protection == "ENABLED" ? true : false

  min_size = var.asg_min_size
  max_size = var.asg_max_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = join("-", [var.name, "capacity-provider"])

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = var.managed_termination_protection

    managed_scaling {
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = var.minimum_scaling_step_size
      instance_warmup_period    = var.instance_warmup_period
      status                    = "ENABLED"
      target_capacity           = var.target_capacity
    }
  }

  tags = var.tags
}

resource "aws_launch_template" "this" {
  name_prefix            = join("-", [var.name, "ecs-launch-template"])
  image_id               = var.ec2_image_id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name
  vpc_security_group_ids = var.security_grp_ids

  user_data     = var.user_data == null ? base64encode(local.default_user_data) : var.user_data
  ebs_optimized = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }
}

resource "aws_iam_instance_profile" "this" {
  name = join("-", [var.name, "ecs-ec2-instance-profile"])
  role = aws_iam_role.ecs_ec2_role.name
}

resource "aws_iam_role" "ecs_ec2_role" {
  name = join("-", [var.name, "ecs-ec2-role"])

  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_ec2_policy" {
  name = join("-", [var.name, "ecs-ec2-policy"])
  role = aws_iam_role.ecs_ec2_role.id

  policy = data.aws_iam_policy_document.ecs_ec2_policy_document.json
}

data "aws_iam_policy_document" "ecs_ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "ecs_ec2_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AllowECS"
    effect = "Allow"

    actions = [
      "ecs:*",
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]

    resources = [
      "*"
    ]
  }
}
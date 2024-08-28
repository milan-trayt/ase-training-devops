data "aws_caller_identity" "current" {}

locals {
  target_groups = var.alb_name != null ? [
    "green",
    "blue",
  ] : []
}

resource "aws_ecs_task_definition" "default" {
  family                   = join("-", [var.name])
  requires_compatibilities = [var.launch_type]
  container_definitions    = var.container_definitions
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  task_role_arn            = var.task_role_arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  pid_mode                 = "task"

  dynamic "volume" {
    for_each = var.task_volumes
    content {
      name      = volume.value["name"]
      host_path = volume.value["host_path"]
    }
  }
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${aws_ecs_task_definition.default.family}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_ecs_service" "default" {
  name                 = join("-", [var.name])
  cluster              = var.aws_ecs_cluster_id
  task_definition      = aws_ecs_task_definition.default.arn
  desired_count        = var.desired_count
  launch_type          = length(var.capacity_provider_strategy) > 0 ? null : var.launch_type
  force_new_deployment = var.force_new_deployment

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy

    content {
      base              = capacity_provider_strategy.value["base"]
      weight            = capacity_provider_strategy.value["weight"]
      capacity_provider = capacity_provider_strategy.value["capacity_provider"]
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []

    content {
      subnets         = var.subnet_ids
      security_groups = var.security_grp_ids
    }
  }

  dynamic "load_balancer" {
    for_each = var.alb_name != null ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.default[0].arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "deployment_circuit_breaker" {
    for_each = var.deployment_controller == "ECS" ? [1] : []
    content {
      enable   = true
      rollback = true
    }
  }

  dynamic "placement_constraints" {
    for_each = var.launch_type == "EC2" ? [1] : []

    content {
      type = var.placement_constraints_type
    }
  }

  lifecycle {
    ignore_changes = [load_balancer, network_configuration, task_definition, desired_count]
  }

  depends_on = [aws_ecs_task_definition.default]
}

resource "aws_lb_target_group" "default" {
  count = length(local.target_groups)

  name                          = join("-", [var.name, count.index])
  port                          = var.container_port
  target_type                   = "instance"
  protocol                      = "HTTPS"
  vpc_id                        = var.vpc_id
  deregistration_delay          = 30
  load_balancing_algorithm_type = var.load_balancing_algorithm_type


  health_check {
    enabled             = true
    protocol            = "HTTPS"
    path                = var.health_check_path
    interval            = 30
    timeout             = 20
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = var.tags
}

resource "aws_alb_listener_rule" "rules" {
  count        = var.alb_name != null ? 1 : 0
  listener_arn = var.alb_listener_arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].arn
  }

  condition {
    path_pattern {
      values = var.service_path
    }
  }

  condition {
    host_header {
      values = var.service_domain_name
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

  depends_on = [aws_lb_target_group.default[0]]
}

resource "aws_appautoscaling_target" "ecs-autoscale" {
  max_capacity       = var.scale_max_capacity
  min_capacity       = var.scale_min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.default.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_usage_scaling_policy" {
  count              = var.memory_scaling_parameters.target_value > 0 ? 1 : 0
  name               = join("-", [var.name, "memory-usage"])
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs-autoscale.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-autoscale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-autoscale.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_scaling_parameters.target_value
    scale_in_cooldown  = var.memory_scaling_parameters.scale_in_cooldown
    scale_out_cooldown = var.memory_scaling_parameters.scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "cpu_usage_scaling_policy" {
  count              = var.cpu_scaling_parameters.target_value > 0 ? 1 : 0
  name               = join("-", [var.name, "cpu-usage"])
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs-autoscale.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-autoscale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-autoscale.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_scaling_parameters.target_value
    scale_in_cooldown  = var.cpu_scaling_parameters.scale_in_cooldown
    scale_out_cooldown = var.cpu_scaling_parameters.scale_out_cooldown
  }
}


## IAM TASK EXECUTION ROLE
resource "aws_iam_role" "ecs_task_execution_role" {
  name = join("-", [var.name, "ecs-task-execution-role"])

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = join("-", [var.name, "ecs-task-execution-policy"])
  role = aws_iam_role.ecs_task_execution_role.id

  policy = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}

resource "aws_iam_role_policy" "ecs_task_execution_policy_alb" {
  count = var.alb_name != null ? 1 : 0
  name  = join("-", [var.name, "ecs-task-execution-policy-alb"])
  role  = aws_iam_role.ecs_task_execution_role.id

  policy = data.aws_iam_policy_document.ecs_alb_task_execution_policy_document[0].json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
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

data "aws_iam_policy_document" "ecs_task_execution_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = var.ecr_repos_arn
  }

  statement {
    sid    = "AllowECRAuthorization"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudwatch"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECS"
    effect = "Allow"

    actions = ["ecs:*"]

    resources = [
      aws_ecs_service.default.id,
      "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.ecs_cluster_name}",
      "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-definition/${aws_ecs_task_definition.default.family}:*",
      "arn:aws:ecs:${var.region}:${data.aws_caller_identity.current.account_id}:task-set/${var.ecs_cluster_name}/*/*/*"
    ]
  }

  statement {
    sid    = "AllowECSCreateTaskSet"
    effect = "Allow"

    actions = ["ecs:CreateTaskSet"]

    resources = ["*"]
  }

}

data "aws_iam_policy_document" "ecs_alb_task_execution_policy_document" {
  count     = var.alb_name != null ? 1 : 0
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AllowELB"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:*"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener-rule/app/${var.alb_name}/*/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener-rule/net/${var.alb_name}/*/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener/app/${var.alb_name}/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:listener/net/${var.alb_name}/*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/${var.alb_name}/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:loadbalancer/net/${var.alb_name}/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:targetgroup/${aws_lb_target_group.default[0].name}/*",
      "arn:aws:elasticloadbalancing:${var.region}:${data.aws_caller_identity.current.account_id}:targetgroup/${aws_lb_target_group.default[1].name}/*"
    ]
  }

  statement {
    sid    = "AllowELBDescribe"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeAccountLimits",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeRules"
    ]
    resources = ["*"]
  }

}


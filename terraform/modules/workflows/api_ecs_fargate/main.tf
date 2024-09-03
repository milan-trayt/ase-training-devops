data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_ecs_task_definition" "TD" {
  task_definition = aws_ecs_task_definition.TD.family
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
    resources = [module.api_ecr.arn]
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

    resources = ["*"]
  }

  statement {
    sid    = "AllowECSCreateTaskSet"
    effect = "Allow"

    actions = ["ecs:CreateTaskSet"]

    resources = ["*"]
  }

  statement {
    sid    = "Cognito"
    effect = "Allow"

    actions = [
      "cognito-identity:*",
      "cognito-idp:*"
    ]
    resources = [
      "arn:aws:cognito-idp:us-east-1:949263681218:userpool/us-east-1_sIftFsIBi",
    ]
  }

}

data "aws_iam_policy_document" "ecs-task-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      for secret in module.api_secrets : secret.arn
    ]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = [module.api_ecr.arn]
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

    resources = ["*"]
  }

  statement {
    sid    = "AllowECSCreateTaskSet"
    effect = "Allow"

    actions = ["ecs:CreateTaskSet"]

    resources = ["*"]
  }

  statement {
    sid    = "Cognito"
    effect = "Allow"

    actions = [
      "cognito-identity:*",
      "cognito-idp:*"
    ]
    resources = [
      "arn:aws:cognito-idp:us-east-1:949263681218:userpool/us-east-1_8EBgtfAA9",
    ]
  }
}

data "aws_iam_policy_document" "api_github_action_policy_document_common" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "LogEventAccess"
    effect = "Allow"

    actions   = ["logs:GetLogEvents"]
    resources = ["*"]
  }

  statement {
    sid    = "CodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "codebuild:BatchGetProjects"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CodeDeploy"
    effect = "Allow"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:GetApplicationRevision",
      "codedeploy:RegisterApplicationRevision",
      "codedeploy:GetDeployment"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [
      "${local.api_secrets_arn}",
    ]
  }

  statement {
    sid    = "AllowECRAuthorization"
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECRPushImage"
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]

    resources = concat([module.api_ecr.arn], var.ecr_repos_arn)
  }

  statement {
    sid    = "AllowECSTaskDefinition"
    effect = "Allow"

    actions   = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowECSUpdateService"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com",
        "codedeploy.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AllowRDSAuth"
    effect = "Allow"

    actions = [
      "rds-db:connect"
    ]
    resources = [
      "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_aurora_cluster_resource_id}/sqlmigration_user"
    ]
  }

  statement {
    sid    = "AutoScaling"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_ecs_cluster" "ECS" {
  name = "milan-splittr-ecs-cluster"

  tags = {
    Name = "my-new-cluster"
  }
}

resource "aws_ecs_service" "ECS-Service" {
  name                               = "milan-splittr-ecs-service"
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  cluster                            = aws_ecs_cluster.ECS.id
  task_definition                    = aws_ecs_task_definition.TD.arn
  force_new_deployment               = true
  scheduling_strategy                = "REPLICA"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  depends_on                         = [aws_alb_listener.Listener, aws_iam_role.task_execution_role, aws_iam_role.task_role]


  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "api"
    container_port   = 3000
  }


  network_configuration {
    assign_public_ip = true
    security_groups  = var.api_security_grp_ids
    subnets          = var.api_subnet_id
  }
}

module "api_ecr" {
  source = "../../services/ecs/ecr"

  name = join("-", [var.stage, var.project, var.module, "api"])

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api"])
    Exposure    = "private"
    Description = "api ecr repository for ${var.stage} environment"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.stage}-milan-splittr-health-api"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "TD" {
  family                   = "milan-splittr-ecs-td"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      "name" : "api",
      "image" : "${module.api_ecr.repo_url}:latest",
      "essential" : true,
      "cpu" : 256,
      "memoryReservation" : 512,
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort" : 3000
        }
      ],
      "readonlyRootFilesystem" : false,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.stage}-milan-splittr-health-api",
          "awslogs-region" : "${data.aws_region.current.name}",
          "awslogs-stream-prefix" : "milan-splittr-api"
        }
      }
    }
  ])
}

resource "aws_iam_role_policy" "ecs-task-execution-role-policy" {
  name   = "milan-splittr-ecs-task-execution-role-policy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}


resource "aws_iam_role_policy" "ecs-task-role-policy" {
  name   = "milan-splittr-ecs-task-role-policy"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.ecs-task-role-policy.json
}


resource "aws_iam_role" "task_execution_role" {
  name               = "milan-splittr-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "task_role" {
  name               = "milan-splittr-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = "EcsAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_lb" "LB" {
  name               = "milan-splittr-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_grp_ids
  subnets            = var.lb_subnet_id

  tags = {
    Name = "LB"
  }
}

resource "aws_alb_listener" "Listener" {
  load_balancer_arn = aws_lb.LB.id
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_lb_target_group.TG.id
    type             = "forward"
  }

  certificate_arn = data.aws_acm_certificate.this.arn
}

data "aws_acm_certificate" "this" {
  domain      = "dev.bibek65.tech"
  most_recent = true
  statuses    = ["ISSUED"]
}

locals {
  api_secrets_arn = var.api_secret_arn != null ? var.api_secret_arn : module.api_secrets[0].arn
}

module "api_secrets" {
  count          = var.api_secret_arn != null ? 0 : 1
  source         = "./../../services/secrets_manager"
  name           = "${var.stage}-api"
  replica_region = var.api_secret_replica_region

  tags = {
    Name        = "api-secrets"
    Exposure    = "private"
    Description = "Key-value secrets for ${var.stage} api"
  }
}

resource "aws_iam_role" "api_github_action_role" {
  name = join("-", [var.stage, var.project, var.module, "api-github-action-role"])

  assume_role_policy = data.aws_iam_policy_document.api_github_action_assume_role_policy.json
}

resource "aws_iam_role_policy" "api_github_action_policy_common" {
  name = join("-", [var.stage, var.project, var.module, "api-github-action-policy-common"])
  role = aws_iam_role.api_github_action_role.id

  policy = data.aws_iam_policy_document.api_github_action_policy_document_common.json
}

data "aws_iam_policy_document" "api_github_action_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      identifiers = ["${var.oidc_provider_arn}"]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:milan-trayt/ase-training-devops:ref:refs/heads/${var.stage}", "repo:milan-trayt/ase-training-devops:environment:${var.stage}*"]
    }
  }
}

resource "aws_lb_target_group" "TG" {
  name        = "milan-splittr-tg"
  port        = "3000"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = {
    Name = "TG"
  }
}
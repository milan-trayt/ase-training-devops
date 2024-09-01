data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  api_secrets_arn = var.api_secret_arn != null ? var.api_secret_arn : module.api_secrets[0].arn

  api_container = [
    {
      "name" : "api",
      "image" : "${module.api_ecr.repo_url}:latest",
      "essential" : true,
      "cpu" : 256,
      "memoryReservation" : 512,
      "portMappings": [
        {
          "containerPort": 443,
          "hostPort": 443
        }
      ],
      "readonlyRootFilesystem" : false,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.stage}-milan-splittr-health-api",
          "awslogs-region" : "${data.aws_region.current.name}",
          "awslogs-stream-prefix" : "${var.stage}-api"
        }
      },
      "environment" : [
        {
          "name" : "NODE_ENV",
          "value" : "${var.stage == "dev" ? "development" : (var.stage == "prod" ? "production" : var.stage)}"
        },
        {
          "name" : "ENVIRONMENT",
          "value" : "${var.stage}"
        },
        {
          "name" : "AWS_REGION",
          "value" : "${data.aws_region.current.name}"
        },
        {
          "name" : "LOAD_ASM_CONFIGURATION",
          "value" : "true"
        },
        {
          "name" : "ASM_SECRET_NAME",
          "value" : "${var.domain_prefix}-api"
        },
        {
          "name" : "ASM_SECRET_REGION",
          "value" : "${data.aws_region.current.name}"
        },
        {
          "name" : "RUNNING_ON_SERVER",
          "value" : "true"
        },
        {
          "name" : "AWS_CONFIG_TYPE",
          "value" : "ecs"
        },
        {
          "name" : "NODE_OPTIONS",
          "value" : "${var.stage == "prod" ? "--max_old_space_size=5120" : "--max_old_space_size=3072"}"
        }
      ]
    }
  ]
}

##Cluster Loadbalancer##
module "alb" {
  source = "./../../services/loadbalancer/alb"
  name   = join("-", [var.stage, var.project, var.module, "alb"])

  internal_loadbalancer = false
  lb_subnet_ids         = var.lb_subnet_ids
  lb_security_grp_ids   = var.lb_security_grp_ids

  elb_logs_bucket_versioning = var.elb_logs_bucket_versioning

  listener_rules = []

  tags = {
    Name        = join("-", [var.project, var.module, "alb"])
    Exposure    = "Public"
    Description = "Public alb for ${var.stage} api "
  }
}

##Container Registry##

module "api_ecr" {
  source = "./../../services/ecs/ecr"

  name = join("-", [var.stage, var.project, var.module, "api"])

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api"])
    Exposure    = "private"
    Description = "api ecr repository for ${var.stage} environment"
  }
}

##ECS Cluster Start ##

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

resource "aws_key_pair" "ssh-key" {
  key_name   = join("-", [var.stage, var.project, var.module, "ecs"])
  public_key = var.ssh_public_key
}

module "api_capacity_provider" {
  source = "./../../services/ecs/capacityprovider"

  ec2_image_id      = var.ec2_image_id
  name              = join("-", [var.stage, var.project, var.module, "ondemand"])
  cluster_name      = join("-", [var.stage, var.project, var.module, "api-cluster"])
  ec2_hostname      = join("-", [var.stage, var.project, var.module, "api"])
  ec2_key_name      = aws_key_pair.ssh-key.key_name
  ec2_instance_type = var.api_instance_type
  vpc_id            = var.vpc_id
  security_grp_ids  = var.api_security_grp_ids
  subnet_ids        = var.api_subnet_ids

  managed_termination_protection = "ENABLED"
  asg_min_size                   = var.api_instance_scaling_parameter.asg_min_size
  asg_max_size                   = var.api_instance_scaling_parameter.asg_max_size
  target_capacity                = var.api_instance_scaling_parameter.target_capacity

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api-cluster"])
    Exposure    = "private"
    Creator     = "milanpokhrel@lftechnology.com"
    Project     = var.project
    Deletable   = "Yes"
    Description = "api ecs cluster for ${var.stage} environment"
  }
}

module "cluster" {
  source = "./../../services/ecs/cluster"

  name               = join("-", [var.stage, var.project, var.module, "api-cluster"])
  capacity_providers = [module.api_capacity_provider.name]

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api-cluster"])
    Exposure    = "private"
    Description = "api ecs cluster for ${var.stage} environment"
  }
}

module "api_service" {
  source = "./../../services/ecs/service"

  name          = join("-", [var.stage, var.project, var.module, "api"])
  region        = data.aws_region.current.name
  vpc_id        = var.vpc_id
  task_role_arn = aws_iam_role.api_ecs_task_role.arn

  ecs_cluster_name      = module.cluster.ecs_cluster_name
  launch_type           = module.cluster.cluster_launch_type
  aws_ecs_cluster_id    = module.cluster.ecs_cluster_id
  ecr_repos_arn         = [module.api_ecr.arn]
  container_definitions = jsonencode(local.api_container)
  security_grp_ids      = var.api_security_grp_ids
  subnet_ids            = var.api_subnet_ids

  log_retention_days = var.cloudwatch_log_retention_days

  health_check_path = "/"
  container_port    = 443
  alb_listener_arn  = module.alb.alb_https_listener_arn
  alb_name          = module.alb.loadbalancer_name

  scale_min_capacity = var.api_service_scaling_parameter.scale_min_capacity
  scale_max_capacity = var.api_service_scaling_parameter.scale_max_capacity
  desired_count      = var.api_service_scaling_parameter.desired_count

  cpu_scaling_parameters = {
    target_value       = var.api_service_scaling_parameter.cpu_scaling_parameters.target_value,
    scale_in_cooldown  = 300,
    scale_out_cooldown = 180
  }

  memory_scaling_parameters = {
    target_value       = var.api_service_scaling_parameter.memory_scaling_parameters.target_value,
    scale_in_cooldown  = 300,
    scale_out_cooldown = 180
  }

  capacity_provider_strategy = [
    {
      base              = 1
      weight            = 1
      capacity_provider = module.api_capacity_provider.name
    }
  ]

  depends_on = [module.api_ecr, module.alb]

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api"])
    Description = "api ecs resource for ${var.stage} environment"
    Exposure    = "Private"
  }
}
###ECS Cluster End###

###ECS API SERVICE ROLE START###

resource "aws_iam_role" "api_ecs_task_role" {
  name = join("-", [var.stage, var.project, var.module, "api-ecs-task-role"])

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy" "api_ecs_task_policy" {
  name = join("-", [var.stage, var.project, var.module, "api-ecs-task-policy"])
  role = aws_iam_role.api_ecs_task_role.id

  policy = module.api_iam_policy.json
}

resource "aws_iam_policy" "api_ecs_task_policy_addons" {
  count       = length(var.task_policies)
  name        = join("-", [var.stage, var.project, var.module, "api-ecs-task-policy-addon", count.index])
  path        = "/api/"
  description = "ECS task policy for API"

  policy = var.task_policies[count.index]
}

resource "aws_iam_role_policy_attachment" "api_ecs_task_policy_attachment" {
  count      = length(var.task_policies)
  role       = aws_iam_role.api_ecs_task_role.id
  policy_arn = aws_iam_policy.api_ecs_task_policy_addons[count.index].arn
}

module "api_iam_policy" {
  source = "./../../services/iam/iam_policy"
  permission_sets = [
    {
      action    = "secretsManagerAccess"
      resources = [local.api_secrets_arn]
    },
    {
      action    = "sesAccess"
      resources = ["*"]
    },
    {
      action = "rdsConnectAccess"
      resources = [
        "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_aurora_cluster_resource_id}/readonly_user",
        "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_aurora_cluster_resource_id}/application_user",
        "arn:aws:rds-db:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:dbuser:${var.rds_aurora_cluster_resource_id}/sqlmigration_user"
      ]
    }
  ]
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = join("-", [var.stage, var.project, var.module, "ecs-task-execution-policy"])
  role = module.api_service.task_execution_role_id

  policy = data.aws_iam_policy_document.api_ecs_task_execution_policy_document.json
}

data "aws_iam_policy_document" "api_ecs_task_execution_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = [local.api_secrets_arn]
  }
}

###ECS API SERVICE ROLE END####

##Deployment roles##
## api start##

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

## api end##
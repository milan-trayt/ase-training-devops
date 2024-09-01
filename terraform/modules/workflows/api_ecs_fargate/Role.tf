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

data "aws_caller_identity" "current" {}
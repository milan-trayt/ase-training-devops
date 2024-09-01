resource "aws_iam_role_policy" "ecs-task-execution-role-policy" {
  name = "milan-splittr-ecs-task-execution-role-policy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}


resource "aws_iam_role_policy" "ecs-task-role-policy" {
  name = "milan-splittr-ecs-task-role-policy"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.ecs-task-role-policy.json
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

}
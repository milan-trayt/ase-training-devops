data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

### Read Role

resource "aws_iam_role" "terraform_read_role" {
  name = join("-", [var.project, var.module, "terraform-github-action-read-role"])
  assume_role_policy = jsonencode({
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_name}:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "${var.oidc_name}:sub" : [
              "repo:milan-trayt/ase-training-devops:*",
            ]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "read_policy" {
  name   = join("-", [var.project, var.module, "read-policy-common"])
  policy = data.aws_iam_policy_document.read_policy.json
}

data "aws_iam_policy_document" "read_policy" {
  version = "2012-10-17"
  statement {
    sid       = "SecretsManager"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "secretsmanager:GetRandomPassword",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets",
      "application-autoscaling:List*"
    ]
  }
}

resource "aws_iam_policy" "terraform_state_lock_write" {
  name   = join("-", [var.project, var.module, "terraform_state_lock_write"])
  policy = data.aws_iam_policy_document.terraform_state_lock_write.json
}

data "aws_iam_policy_document" "terraform_state_lock_write" {
  version = "2012-10-17"
  statement {
    sid       = "SecretsManager"
    effect    = "Allow"
    resources = ["arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project}-${var.module}-tflock-${var.stage}"]
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ReadOnlyAccess" {
  role       = aws_iam_role.terraform_read_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonEventBridgeSchedulerReadOnlyAccess" {
  role       = aws_iam_role.terraform_read_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "Terraform_State_Lock_Write" {
  role       = aws_iam_role.terraform_read_role.name
  policy_arn = aws_iam_policy.terraform_state_lock_write.arn
}

resource "aws_iam_role_policy_attachment" "custom_read" {
  role       = aws_iam_role.terraform_read_role.name
  policy_arn = aws_iam_policy.read_policy.arn
}

### Write Role

resource "aws_iam_role" "terraform_write_role" {
  name = join("-", [var.project, var.module, "terraform-github-action-write-role"])
  assume_role_policy = jsonencode({
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_name}:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "${var.oidc_name}:sub" : [
              "repo:milan-trayt/ase-training-devops:*",
            ]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "write_policy" {
  name   = join("-", [var.project, var.module, "write-policy"])
  policy = data.aws_iam_policy_document.write_policy.json
}

resource "aws_iam_role_policy_attachment" "terraform_write" {
  role       = aws_iam_role.terraform_write_role.name
  policy_arn = aws_iam_policy.write_policy.arn
}

data "aws_iam_policy_document" "write_policy" {
  version = "2012-10-17"
  statement {
    sid       = "TerraformWrite"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecs:*",
      "ecr:*",
      "application-autoscaling:*",
      "sqs:*",
      "wafv2:*",
      "rds:*",
      "codebuild:*",
      "waf:*",
      "tag:*",
      "sts:*",
      "sns:*",
      "ses:*",
      "secretsmanager:*",
      "schemas:*",
      "scheduler:*",
      "s3:*",
      "route53:*",
      "networkmanager:*",
      "network-firewall:*",
      "logs:*",
      "lambda:*",
      "kms:*",
      "inspector:*",
      "inspector2:*",
      "iam:*",
      "guardduty:*",
      "firehose:*",
      "events:*",
      "es:*",
      "elasticloadbalancing:*",
      "elasticache:*",
      "ec2:*",
      "dynamodb:*",
      "dlm:*",
      "codedeploy:*",
      "cloudwatch:*",
      "cloudfront:*",
      "backup:*",
      "autoscaling:*",
      "autoscaling-plans:*",
      "acm:*",
      "sso:*",
      "identitystore:*",
      "workspaces:*",
      "ds:*",
      "backup-storage:*",
      "organizations:*"
    ]
  }
}

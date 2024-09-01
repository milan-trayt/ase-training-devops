locals {
  portal_repo = var.portal_repo != null ? var.portal_repo : "ase-training-devops"
  pr_repos    = formatlist("repo:milan-trayt/%s:*", var.pr_repos)

  cloudfront_response_functions = []

  block_public_acls       = var.disable_public_bucket
  block_public_policy     = var.disable_public_bucket
  restrict_public_buckets = var.disable_public_bucket
  ignore_public_acls      = var.disable_public_bucket
  content_security_policy = join("; ", [for key, value in var.content_security_policy : "${key} ${value}"])
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

provider "aws" {
  alias  = "cloudfront_certificate"
  region = "us-east-1"
}

## CLOUDFRONT Distribution###
resource "aws_cloudfront_origin_access_identity" "portal" {
  comment = "Access identity for ${var.portal_name} portal s3"
}

resource "aws_cloudfront_distribution" "portal" {
  origin {
    domain_name = module.portal.bucket_regional_domain_name
    origin_id   = module.portal.bucket_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.portal.cloudfront_access_identity_path
    }
  }
  custom_error_response {
    error_code            = "400"
    error_caching_min_ttl = 300
    response_code         = "200"
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_code            = "403"
    error_caching_min_ttl = 300
    response_code         = "200"
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = 0
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.portal.bucket_id

    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

  }

  price_class = "PriceClass_100"
  web_acl_id  = var.waf_arn

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_location
    }
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "portal-cloudfront"])
    Exposure    = "Public"
    Description = "cloudfront distribution for ${var.stage} portal"
  }
}

### S3 Bucket to host the frontend
module "portal" {
  source = "./../../services/s3/bucket"

  bucket_name = var.portal_bucket_name

  force_destroy           = false
  block_public_acls       = local.block_public_acls
  block_public_policy     = local.block_public_policy
  restrict_public_buckets = local.restrict_public_buckets
  ignore_public_acls      = local.ignore_public_acls

  versioning = var.portal_bucket_replication ? "Enabled" : var.portal_bucket_versioning

  replication_configuration = var.portal_bucket_replication ? {
    priority            = 1
    replica_bucket_name = join(".", ["backup", var.portal_bucket_name])
  } : {}

  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Cloudfront-access"
    Statement = [
      {
        Sid       = "ReadAllow"
        Effect    = "Allow"
        Principal = { "AWS" : [aws_cloudfront_origin_access_identity.portal.iam_arn] }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          module.portal.bucket_arn,
          "${module.portal.bucket_arn}/*",
        ]
      },
      {
        Sid       = "HttpDeny"
        Effect    = "Deny"
        Principal = "*"
        Action : "s3:*"
        Resource = [
          module.portal.bucket_arn,
          "${module.portal.bucket_arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })

  replica_bucket_policy = var.portal_bucket_replication ? jsonencode({
    Version = "2012-10-17"
    Id      = "Cloudfront-access"
    Statement = [
      {
        Sid       = "ReadAllow"
        Effect    = "Allow"
        Principal = { "AWS" : [aws_cloudfront_origin_access_identity.portal.iam_arn] }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          module.portal.replica_bucket_arn,
          "${module.portal.replica_bucket_arn}/*",
        ]

      },
      {
        Sid       = "HttpDeny"
        Effect    = "Deny"
        Principal = "*"
        Action : "s3:*"
        Resource = [
          module.portal.replica_bucket_arn,
          "${module.portal.replica_bucket_arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  }) : null

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, var.portal_name, "portal-s3"])
    Exposure    = "Public"
    Description = "frontend s3 for ${var.stage} ${var.portal_name} portal"
  }
}

### Secret for the portal
module "portal_secrets" {
  source         = "./../../services/secrets_manager"
  name           = "${var.stage}-${var.portal_name}-portal"
  replica_region = var.secret_replica_region

  tags = {
    Name        = "${var.portal_name}-portal"
    Exposure    = "private"
    Description = "Key-value secrets for ${var.stage} ${var.portal_name} portal"
  }
}

### IAM roles for web portal ci/cd

resource "aws_iam_role" "portal_github_action_role" {
  name = join("-", [var.portal_name, "portal", var.project, var.module, "github-action-role"])

  assume_role_policy = data.aws_iam_policy_document.portal_github_action_assume_role_policy.json
}

resource "aws_iam_role_policy" "portal_github_action_policy" {
  name = join("-", [var.project, var.module, var.portal_name, "portal-github-action-policy-common"])
  role = aws_iam_role.portal_github_action_role.id

  policy = data.aws_iam_policy_document.portal_github_action_policy_document.json
}

data "aws_iam_policy_document" "portal_github_action_assume_role_policy" {
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
      values   = var.portal_name == "pullrequest" ? local.pr_repos : (var.stage == "dev" ? ["repo:milan-trayt/${local.portal_repo}:*", "repo:milan-trayt/${local.portal_repo}:environment:*"] : (var.stage == "prod" ? ["repo:milan-trayt/${local.portal_repo}:ref:refs/heads/master", "repo:milan-trayt/${local.portal_repo}:environment:prod*"] : ["repo:milan-trayt/${local.portal_repo}:ref:refs/heads/${var.stage}", "repo:milan-trayt/${local.portal_repo}:environment:${var.stage}"]))
    }
  }
}

data "aws_iam_policy_document" "portal_github_action_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    sid    = "secretmanager"
    effect = "Allow"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]

    resources = var.portal_name == "pullrequest" ? ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:secret:${var.stage}-*-portal*"] : [
      "${module.portal_secrets.arn}"
    ]
  }

  statement {
    sid    = "s3access"
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket"
    ]

    resources = [
      "${module.portal.bucket_arn}",
      "${module.portal.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "cloudfront"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      "${aws_cloudfront_distribution.portal.arn}"
    ]
  }

  statement {
    sid    = "ECR"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "*"
    ]
  }
}

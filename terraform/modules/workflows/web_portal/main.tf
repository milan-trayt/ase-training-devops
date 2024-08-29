locals {
  portal_repo = var.portal_repo != null ? var.portal_repo : "${var.portal_name}-portal"
  pr_repos    = formatlist("repo:trayt-health/%s:*", var.pr_repos)

  ddb_table_prefix              = var.ddb_table_prefix
  cloudfront_response_functions = []
  cloudfront_request_functions  = concat(var.index_file_server ? [aws_cloudfront_function.indexfile_server[0].arn] : [], var.portal_redirect_url != null ? [aws_cloudfront_function.redirect[0].arn] : [])

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
resource "aws_cloudfront_function" "indexfile_server" {
  count = var.index_file_server ? 1 : 0

  name    = join("-", [var.stage, var.project, var.module, var.portal_name, "indexfile-server"])
  runtime = "cloudfront-js-1.0"
  comment = "append index.html to request if doesn't exist"
  publish = true
  code    = file("./cloudfront_functions/pullrequest-viewer-request.js")
}

resource "aws_cloudfront_function" "redirect" {
  count = var.portal_redirect_url != null ? 1 : 0

  name    = join("-", [var.stage, var.project, var.module, var.portal_name, "redirect"])
  runtime = "cloudfront-js-1.0"
  comment = "Function to manipulate/handle viewer requests for ${var.stage} ${var.portal_name} portal"
  publish = true
  code    = templatefile("./cloudfront_functions/redirect.tftpl", { portal_redirect_url = var.portal_redirect_url })

}

resource "aws_cloudfront_response_headers_policy" "default" {
  name = join("-", [var.stage, var.project, var.module, var.portal_name, "response-headers"])

  custom_headers_config {
    items {
      header   = "server"
      override = true
      value    = "none"
    }

    dynamic "items" {
      for_each = var.enforce_csp ? [] : [1]
      content {
        header   = "content-security-policy-report-only"
        override = true
        value    = local.content_security_policy
      }
    }
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    dynamic "content_security_policy" {
      for_each = var.enforce_csp ? [1] : []
      content {
        content_security_policy = local.content_security_policy
        override                = false
      }
    }

  }
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

  aliases = distinct(concat([var.portal_domain], var.portal_domain_aliases))
  default_cache_behavior {
    response_headers_policy_id = aws_cloudfront_response_headers_policy.default.id
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = module.portal.bucket_id

    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    dynamic "function_association" {
      for_each = local.cloudfront_request_functions
      content {
        event_type   = "viewer-request"
        function_arn = function_association.value
      }
    }

    dynamic "function_association" {
      for_each = local.cloudfront_response_functions
      content {
        event_type   = "viewer-response"
        function_arn = function_association.value
      }
    }
  }

  price_class = "PriceClass_100"
  web_acl_id  = var.waf_arn

  logging_config {
    include_cookies = false
    bucket          = join(".", [var.portal_access_log_bucket_name, "s3.amazonaws.com"])
    prefix          = join("_", ["cloudfront", var.portal_name, "portal"])
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
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
  source = "./../../service/s3/bucket"

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

### Certificate for the portal
resource "aws_acm_certificate" "certificate" {
  provider = aws.cloudfront_certificate

  domain_name               = var.portal_domain
  subject_alternative_names = setsubtract(var.portal_domain_aliases, [var.portal_domain])
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, var.portal_name, "portal-certificates"])
    Description = "certificates for ${var.stage} ${var.portal_name} portal cloudfront"
    Exposure    = "Private"
  }
}

### Secret for the portal
module "portal_secrets" {
  source         = "./../../service/secrets_manager"
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
      values   = var.portal_name == "pullrequest" ? local.pr_repos : (var.stage == "dev" || var.stage == "qa" ? ["repo:trayt-health/${local.portal_repo}:*", "repo:trayt-health/${local.portal_repo}:environment:*"] : (var.stage == "prod" ? ["repo:trayt-health/${local.portal_repo}:ref:refs/heads/master", "repo:trayt-health/${local.portal_repo}:environment:prod*"] : ["repo:trayt-health/${local.portal_repo}:ref:refs/heads/${var.stage}", "repo:trayt-health/${local.portal_repo}:environment:${var.stage}"]))
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
    sid    = "dynamodb"
    effect = "Allow"

    actions = [
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${local.ddb_table_prefix}_ClientApps"
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

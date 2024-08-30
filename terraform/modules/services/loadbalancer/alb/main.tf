resource "aws_lb" "default" {
  name                       = var.name
  load_balancer_type         = "application"
  internal                   = var.internal_loadbalancer
  subnets                    = var.lb_subnet_ids
  security_groups            = var.lb_security_grp_ids
  enable_deletion_protection = var.alb_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.elb_logs_s3.id
    enabled = true
  }

  tags = var.tags
}

resource "aws_alb_listener" "default_http" {
  load_balancer_arn = aws_lb.default.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "Milan"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
}

resource "aws_lb_listener" "default_https" {
  load_balancer_arn = aws_lb.default.arn
  certificate_arn   = aws_acm_certificate.cert.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Unable to reach the target group."
      status_code  = "400"
    }
  }
}

resource "aws_alb_listener_rule" "rules" {
  count = length(var.listener_rules)

  listener_arn = aws_lb_listener.default_https.arn
  action {
    type             = var.listener_rules[count.index].action
    target_group_arn = var.listener_rules[count.index].target_group_arn
  }

  condition {
    host_header {
      values = var.listener_rules[count.index].host_header
    }
  }

  condition {
    path_pattern {
      values = var.listener_rules[count.index].path_pattern
    }
  }
}


//s3 bucket for loadbalancer access logs
data "aws_elb_service_account" "elb_account" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "elb_logs_s3" {
  bucket        = "${var.name}-alb-access-logs"
  force_destroy = false

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.elb_logs_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.elb_logs_s3.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = ""
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.elb_logs_s3.id
  versioning_configuration {
    status = var.elb_logs_bucket_versioning
  }
}

data "aws_iam_policy_document" "elb_policy_doc" {
  statement {
    principals {
      identifiers = [data.aws_elb_service_account.elb_account.arn]
      type        = "AWS"
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.elb_logs_s3.arn}/AWSLogs/${data.aws_caller_identity.current.id}/*"
    ]
  }
  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.elb_logs_s3.arn}/AWSLogs/${data.aws_caller_identity.current.id}/*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.elb_logs_s3.arn}/AWSLogs/${data.aws_caller_identity.current.id}/*"
    ]
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
  statement {
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.elb_logs_s3.arn
    ]
  }

  statement {
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.elb_logs_s3.arn,
      "${aws_s3_bucket.elb_logs_s3.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false",
      ]
    }
  }
}

#s3 bucket policy for elb accesslogs
resource "aws_s3_bucket_policy" "alb_s3_ploicy" {
  bucket = aws_s3_bucket.elb_logs_s3.id
  policy = data.aws_iam_policy_document.elb_policy_doc.json
}

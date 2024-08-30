locals {
  tags = merge(var.tags, {
    Name = var.bucket_name
    }
  )

  default_bucket_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "HttpDeny"
    Statement = [
      {
        Sid       = "HttpDeny"
        Effect    = "Deny"
        Principal = "*"
        Action : "s3:*"
        Resource = [
          aws_s3_bucket.default.arn,
          "${aws_s3_bucket.default.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })

  default_replica_bucket_policy = length(keys(var.replication_configuration)) > 0 ? jsonencode({
    Version = "2012-10-17"
    Id      = "HttpDeny"
    Statement = [
      {
        Sid       = "HttpDeny"
        Effect    = "Deny"
        Principal = "*"
        Action : "s3:*"
        Resource = [
          aws_s3_bucket.replica[0].arn,
          "${aws_s3_bucket.replica[0].arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  }) : null
}

data "aws_caller_identity" "current" {}

provider "aws" {
  alias  = "bucket_replica"
  region = var.replica_region
}

resource "aws_s3_bucket" "default" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_policy" "default" {
  bucket     = aws_s3_bucket.default.id
  depends_on = [aws_s3_bucket.default]

  policy = var.bucket_policy != null ? var.bucket_policy : local.default_bucket_policy
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.default.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.default.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.server_access_log_bucket != null ? 1 : 0
  bucket = aws_s3_bucket.default.id

  target_bucket = var.server_access_log_bucket
  target_prefix = var.bucket_name

  depends_on = [aws_s3_bucket.default]
}

##Bucket Replication Configuration
resource "aws_s3_bucket" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica

  bucket        = contains(keys(var.replication_configuration), "replica_bucket_name") ? var.replication_configuration.replica_bucket_name : join(".", ["backup", var.bucket_name])
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_logging" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 && var.server_access_log_bucket != null ? 1 : 0
  provider = aws.bucket_replica

  bucket = aws_s3_bucket.replica[0].id

  target_bucket = join(".", ["backup", var.server_access_log_bucket])
  target_prefix = aws_s3_bucket.replica[0].id

  depends_on = [aws_s3_bucket.replica]
}

resource "aws_s3_bucket_policy" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica

  bucket     = aws_s3_bucket.replica[0].id
  depends_on = [aws_s3_bucket.replica]

  policy = var.replica_bucket_policy != null ? var.replica_bucket_policy : local.default_replica_bucket_policy
}

resource "aws_s3_bucket_public_access_block" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica

  bucket = aws_s3_bucket.replica[0].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 && var.acl_enabled == true ? 1 : 0
  provider = aws.bucket_replica

  bucket = aws_s3_bucket.replica[0].id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica

  bucket = aws_s3_bucket.replica[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "replica" {
  count    = length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica

  bucket = aws_s3_bucket.replica[0].id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  count = length(keys(var.replication_configuration)) > 0 ? 1 : 0

  depends_on = [aws_s3_bucket_versioning.this]

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.default.id

  rule {
    id = join("-", [var.bucket_name, "replication"])

    status = "Enabled"

    filter {}

    delete_marker_replication {
      status = "Disabled"
    }

    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = var.sse_kms_encrypted_objects
      }
    }

    priority = var.replication_configuration.priority

    destination {
      bucket = aws_s3_bucket.replica[0].arn

      encryption_configuration {
        replica_kms_key_id = var.replica_kms_key_id == null ? "arn:aws:kms:${var.replica_region}:${data.aws_caller_identity.current.account_id}:alias/aws/s3" : var.replica_kms_key_id
      }
    }
  }
}

resource "aws_iam_role" "replication" {
  count = length(keys(var.replication_configuration)) > 0 ? 1 : 0

  name = join("-", [var.bucket_name, "replication-role"])

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  count = length(keys(var.replication_configuration)) > 0 ? 1 : 0

  name = join("-", [var.bucket_name, "replication-policy"])

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.default.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.default.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replica[0].arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = length(keys(var.replication_configuration)) > 0 ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

resource "aws_s3_bucket_lifecycle_configuration" "default" {
  bucket = aws_s3_bucket.default.id
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  rule {
    id     = join("-", [aws_s3_bucket.default.id, "lifecycle-policy"])
    status = length(var.lifecycle_rules) > 0 ? "Enabled" : "Disabled"

    dynamic "transition" {
      for_each = var.lifecycle_rules
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.lifecycle_rules
      content {
        noncurrent_days = noncurrent_version_transition.value.days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }

  }
}

resource "aws_s3_bucket_lifecycle_configuration" "replica" {
  bucket   = aws_s3_bucket.replica[0].id
  count    = length(var.lifecycle_rules) > 0 && length(keys(var.replication_configuration)) > 0 ? 1 : 0
  provider = aws.bucket_replica
  rule {
    id     = join("-", [aws_s3_bucket.replica[0].id, "lifecycle-policy"])
    status = length(var.lifecycle_rules) > 0 ? "Enabled" : "Disabled"

    dynamic "transition" {
      for_each = var.lifecycle_rules
      content {
        days          = transition.value.days
        storage_class = transition.value.storage_class
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.lifecycle_rules
      content {
        noncurrent_days = noncurrent_version_transition.value.days
        storage_class   = noncurrent_version_transition.value.storage_class
      }
    }

  }
}
resource "aws_ecr_repository" "default" {
  name = var.name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "untagged_expire_policy" {
  repository = aws_ecr_repository.default.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

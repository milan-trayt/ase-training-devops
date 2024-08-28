variable "permissable_actions" {
  type = map(any)
  default = {
    secretsManagerAccess = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:ListSecretVersionIds"
    ],
    dynamoCrudAccess = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeStream",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListBackups",
      "dynamodb:ListContributorInsights",
      "dynamodb:ListExports",
      "dynamodb:ListGlobalTables",
      "dynamodb:ListStreams",
      "dynamodb:ListTables",
      "dynamodb:PurchaseReservedCapacityOfferings",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
    dynamoStreamAccess = [
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:DescribeStream",
      "dynamodb:ListStreams"
    ]
    rdsConnectAccess = [
      "rds-db:connect"
    ],
    sqsQueueAccess = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:List*",
      "sqs:Get*",
      "sqs:DeleteMessage"
    ],
    s3FullAccess = [
      "s3:*"
    ],
    sesAccess = [
      "ses:VerifyEmailAddress",
      "ses:SetIdentityNotificationTopic",
      "ses:SetIdentityMailFromDomain",
      "ses:SendRawEmail",
      "ses:SendEmail",
      "ses:SendBounce"
    ],
    inspector2FullAccess = [
      "inspector2:*"
    ],
    ec2StartStop = [
      "ec2:Start*",
      "ec2:Stop*"
    ],
    ssmAgentAccess = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ],
    guarddutyMalwareScan = [
      "ec2:DescribeInstances",
      "guardduty:StartMalwareScan"
    ],
    iamGetRole = [
      "iam:GetRole"
    ]
  }
}

variable "permission_sets" {
  type = list(object({
    action    = string
    resources = list(string)
  }))
  default = []
  validation {
    error_message = "Invalid permission_set"
    condition = contains([for entity in var.permission_sets : try(
      entity.action == "secretsManagerAccess" ||
      entity.action == "dynamoCrudAccess" ||
      entity.action == "dynamoStreamAccess" ||
      entity.action == "rdsConnectAccess" ||
      entity.action == "sqsQueueAccess" ||
      entity.action == "s3FullAccess" ||
      entity.action == "sesAccess" ||
      entity.action == "inspector2FullAccess" ||
      entity.action == "ec2StartStop" ||
      entity.action == "ssmAgentAccess" ||
      entity.action == "guarddutyMalwareScan" ||
      entity.action == "iamGetRole"
    , false)], true)
  }
}

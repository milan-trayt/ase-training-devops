# IAM Policy Creator
This directory contains a Terraform module to create pre-defined IAM Policies that are used by multiple resources.

## How do I use this?
This directory defines a Terraform module. You can use this in your code by adding a `module` configuration and setting its `source` parameter to the relative path of this folder.

Create a `permission_sets` of objects. Each object contains an action and a resource key. The action is a human-readable abstraction, such as "dynamoCrudAccess" that actually maps to several different policy statements. Then an array of resources that target the approved action.

## Example
```
module "iam_policy" {
  source = "./modules/service/iam_policy"
  count  = var.stage == "dev" || var.stage == "qa" || var.stage == "staging" || var.stage == "demo" || var.stage == "prod" ? 1 : 0
  permission_sets = [
    {
      action = "secretsManagerAccess"
      resources = [
        "${module.api_secrets.arn}",
      ]
    },
    {
      action = "dynamoCrudAccess"
      resources = [
        "arn:aws:dynamodb:us-west-2:${var.allowed_account_ids[0]}:table/${var.ddb_table_prefix}_*",
        "arn:aws:dynamodb:us-west-2:${var.allowed_account_ids[0]}:table/${var.ddb_table_prefix}_*/index/*",
        "arn:aws:dynamodb:us-west-2:${var.allowed_account_ids[0]}:table/${var.ddb_table_prefix}_*/stream/*",
        "arn:aws:dynamodb:us-west-2:${var.allowed_account_ids[0]}:table/${var.ddb_table_prefix}_*/backup/*"
      ]
    },
        {
      action = "rdsConnectAccess"
      resources = [
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.this.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/readonly_user",
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.this.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/application_user",
      "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.this.account_id}:dbuser:${module.rds-aurora[0].cluster_resource_id}/sqlmigration_user"
    ]
    },
  ]
}
```

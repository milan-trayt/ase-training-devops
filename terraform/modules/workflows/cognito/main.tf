resource "aws_cognito_user_pool" "this" {
  name                = var.user_pool_name
  username_attributes = var.username_attributes
  email_configuration {
    email_sending_account = var.email_sending_account
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }
  auto_verified_attributes = var.username_attributes
  username_configuration {
    case_sensitive = false
  }
  deletion_protection = var.deletion_protection ? "ACTIVE" : "INACTIVE"
}
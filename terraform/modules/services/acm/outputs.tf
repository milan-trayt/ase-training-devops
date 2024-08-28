output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

locals {
  domain_validation_options = [for data in aws_acm_certificate.cert.domain_validation_options : data]
}

output "resource_record_type" {
  value = local.domain_validation_options[0].resource_record_type
}

output "resource_record_name" {
  value = local.domain_validation_options[0].resource_record_name
}

output "resource_record_value" {
  value = local.domain_validation_options[0].resource_record_value
}

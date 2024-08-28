resource "aws_route53_record" "this" {
  count   = length(var.record_details)
  zone_id = var.record_details[count.index].hosted_zone_id
  name    = var.record_details[count.index].dns_record_name
  type    = var.record_details[count.index].dns_record_type
  ttl     = var.record_details[count.index].dns_record_ttl
  records = [for value in var.record_details[count.index].dns_record_value : value]
}

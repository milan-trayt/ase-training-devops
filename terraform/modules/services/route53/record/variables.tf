variable "record_details" {
  type = list(object({ hosted_zone_id = string, dns_record_name = string, dns_record_type = string, dns_record_ttl = string, dns_record_value = set(string) }))
}

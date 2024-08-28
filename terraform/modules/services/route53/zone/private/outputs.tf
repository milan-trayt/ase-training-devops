output "zone_id" {
  value       = aws_route53_zone.primary.zone_id
  description = "zone id for the hosted zone"
}

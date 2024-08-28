resource "aws_route53_zone" "primary" {
  name = var.primary_domain_name
  vpc {
    vpc_id = var.vpc_id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = var.tags
}

resource "aws_route53_record" "ns_record" {
  allow_overwrite = true
  name            = var.primary_domain_name
  ttl             = 172800
  type            = "NS"
  zone_id         = aws_route53_zone.primary.zone_id

  records = [
    aws_route53_zone.primary.name_servers[0],
    aws_route53_zone.primary.name_servers[1],
    aws_route53_zone.primary.name_servers[2],
    aws_route53_zone.primary.name_servers[3],
  ]
}

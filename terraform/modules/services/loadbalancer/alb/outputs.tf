output "id" {
  value = aws_lb.default.id
}

output "loadbalance_dns_name" {
  value = aws_lb.default.dns_name
}

output "loadbalancer_arn" {
  value = aws_lb.default.arn
}

output "loadbalancer_name" {
  value = aws_lb.default.name
}

output "domain_name" {
  value = aws_lb.default.dns_name
}

output "alb_https_listener_arn" {
  value       = aws_lb_listener.default_https.arn
  sensitive   = true
  description = "arn for lb https listener"
  depends_on  = []
}

output "alb_http_listener_arn" {
  value       = aws_alb_listener.default_http.arn
  sensitive   = true
  description = "arn for lb http listener"
}

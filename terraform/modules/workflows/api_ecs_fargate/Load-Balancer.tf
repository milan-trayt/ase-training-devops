resource "aws_lb" "LB" {
  name               = "milan-splittr-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_grp_ids
  subnets            = var.lb_subnet_id

  tags = {
    Name = "LB"
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "pokhrelmilan.com.np"
    organization = "Milan"
  }

  validity_period_hours = 36

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
}

resource "aws_alb_listener" "Listener" {
  load_balancer_arn = aws_lb.LB.id
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_lb_target_group.TG.id
    type             = "forward"
  }

  certificate_arn = aws_acm_certificate.cert.arn
}
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

resource "aws_alb_listener" "Listener" {
  load_balancer_arn = aws_lb.LB.id
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    target_group_arn = aws_lb_target_group.TG.id
    type             = "forward"
  }

  certificate_arn = data.aws_acm_certificate.this.arn
}

data "aws_acm_certificate" "this" {
  domain      = "dev.bibek65.tech"
  most_recent = true
  statuses    = ["ISSUED"]
}
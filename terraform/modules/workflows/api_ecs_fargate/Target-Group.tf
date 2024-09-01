resource "aws_lb_target_group" "TG" {
  name        = "milan-splittr-tg"
  port        = "3000"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = {
    Name = "TG"
  }
}
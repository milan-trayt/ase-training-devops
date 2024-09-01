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
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.TG.id
    type             = "forward"
  }
}
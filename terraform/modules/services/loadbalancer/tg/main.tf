resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    enabled           = true
    protocol          = var.protocol
    path              = var.health_check_path
    interval          = 60
    timeout           = 30
    healthy_threshold = 3
  }

  tags = var.tags
}


resource "aws_ecs_cluster" "default" {
  name = var.name
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.default.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.capacity_providers
    content {
      base              = 1
      weight            = 1
      capacity_provider = var.capacity_providers[0]
    }
  }
}

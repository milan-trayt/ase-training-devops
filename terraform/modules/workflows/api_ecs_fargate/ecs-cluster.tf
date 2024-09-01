resource "aws_ecs_cluster" "ECS" {
  name = "milan-splittr-ecs-cluster"

  tags = {
    Name = "my-new-cluster"
  }
}   
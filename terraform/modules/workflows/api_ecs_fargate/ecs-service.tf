resource "aws_ecs_service" "ECS-Service" {
  name                               = "milan-splittr-ecs-service"
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  cluster                            = aws_ecs_cluster.ECS.id
  task_definition                    = aws_ecs_task_definition.TD.arn
  force_new_deployment               = true
  scheduling_strategy                = "REPLICA"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  depends_on                         = [aws_alb_listener.Listener, aws_iam_role.task_execution_role, aws_iam_role.task_role]


  load_balancer {
    target_group_arn = aws_lb_target_group.TG.arn
    container_name   = "api"
    container_port   = 3000
  }


  network_configuration {
    assign_public_ip = true
    security_groups  = var.api_security_grp_ids
    subnets          = var.api_subnet_id
  }
}

module "api_ecr" {
  source = "../../services/ecs/ecr"

  name = join("-", [var.stage, var.project, var.module, "api"])

  tags = {
    Name        = join("-", [var.stage, var.project, var.module, "api"])
    Exposure    = "private"
    Description = "api ecr repository for ${var.stage} environment"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.stage}-milan-splittr-health-api"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "TD" {
  family                   = "milan-splittr-ecs-td"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      "name" : "api",
      "image" : "${module.api_ecr.repo_url}:latest",
      "essential" : true,
      "cpu" : 256,
      "memoryReservation" : 512,
      "portMappings" : [
        {
          "containerPort" : 3000,
          "hostPort" : 3000
        }
      ],
      "readonlyRootFilesystem" : false,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/${var.stage}-milan-splittr-health-api",
          "awslogs-region" : "${data.aws_region.current.name}",
          "awslogs-stream-prefix" : "milan-splittr-api"
        }
      }
    }
  ])
}


data "aws_ecs_task_definition" "TD" {
  task_definition = aws_ecs_task_definition.TD.family
}

data "aws_region" "current" {}

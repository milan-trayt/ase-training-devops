resource "aws_iam_role" "task_execution_role" {
  name               = "milan-splittr-ecs-task-execution-role"
  assume_role_policy = file("${path.module}/iam-role.json")
}

resource "aws_iam_role" "task_role" {
  name               = "milan-splittr-ecs-task-role"
  assume_role_policy = file("${path.module}/iam-role.json")
}

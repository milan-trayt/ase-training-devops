resource "aws_iam_role" "task_execution_role" {
  name               = "milan-splittr-ecs-task-execution-role"
  assume_role_policy = file("${path.module}/iam-role.json")
}

resource "aws_iam_role" "task_role" {
  name               = "milan-splittr-ecs-task-role"
  assume_role_policy = file("${path.module}/iam-role.json")
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

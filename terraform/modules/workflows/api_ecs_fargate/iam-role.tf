resource "aws_iam_role" "iam-role" {
  name               = "ECS-execution-role-milan-splittr"
  assume_role_policy = file("${path.module}/iam-role.json")
}

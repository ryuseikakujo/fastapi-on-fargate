resource "aws_cloudwatch_log_group" "ecs" {
  name = "/aws/ecs/${var.app_name}/cluster"
}

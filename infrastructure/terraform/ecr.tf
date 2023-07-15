data "aws_ecr_repository" "fastapi" {
  name = "${var.fastapi}-fastapi"
}

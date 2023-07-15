resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "fasrapi" {
  family                   = "${var.app_name}-fastapi"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name    = "${var.ap_name}-fastapi"
      image   = "${data.aws_ecr_repository.fastapi.repository_url}:latest"
      command = ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
      portMappings = [
        {
          hostPort      = 80
          containerPort = 80
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
        }
      },
      environment = [
        {
          name  = "TEST1",
          value = 1
        },
        {
          name  = "TEST2",
          value = 2
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "fastapi" {
  name            = "${var.app_name}-fastapi"
  cluster         = aws_ecs_cluster.main.name
  launch_type     = "FARGATE"
  desired_count   = length(var.private_subnet_cidrs)
  task_definition = aws_ecs_task_definition.fastapi.arn

  network_configuration {
    subnets         = [for s in aws_subnet.privates : s.id]
    security_groups = [aws_security_group.ecs.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.app_name}-fastapi"
    container_port   = "80"
  }

  lifecycle {
    ignore_changes = [
      desired_count,
    ]
  }

  depends_on = [aws_lb_listener_rule.main]
}


# Security Group
resource "aws_security_group" "ecs" {
  name   = "${var.app_name}-ecs"
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs"
  }
}

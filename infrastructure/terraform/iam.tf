resource "aws_iam_openid_connect_provider" "main" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.app_name}-github-actions"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Principal = {
            Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
          },
          Action = [
            "sts:AssumeRoleWithWebIdentity"
          ],
          Effect = "Allow"
          Condition = {
            StringLike = {
              "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
              "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
            }
          },
        }
      ]
    }
  )
}

resource "aws_iam_policy" "github_actions_policy" {
  name = "${var.app_name}-github-actions-policy"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "ImageUploader",
          Action = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
          ],
          Effect   = "Allow"
          Resource = "*"
        }
      ],
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_policy_attachment" {
  policy_arn = aws_iam_policy.github_actions_policy.arn
  role       = aws_iam_role.github_actions.id
}

resource "aws_iam_role_policy_attachment" "github_actions_ecs_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.github_actions.id
}

# ECSタスク実行Role
data "aws_iam_policy_document" "ecs_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.app_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_policy.json
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name = "${var.app_name}-ecs-execution-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Action : [
          "elasticloadbalancing:*",
          "ecs:*",
          "elasticloadbalancing:*",
          "ecr:*",
          "cloudwatch:*",
          "s3:*",
          "logs:*"
          # "ssm:*",
          # "rds:*",
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

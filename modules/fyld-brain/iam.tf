# ECS Common
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.env}-fyld-brain-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task role
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-${var.env}-fyld-brain-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
  statement {
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    actions   = ["cloudfront:CreateInvalidation"]
    resources = ["*"]
  }
  statement {
    actions   = ["cognito-idp:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["ses:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["sns:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["sqs:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["execute-api:ManageConnections"]
    resources = ["arn:aws:execute-api:*:*:**/@connections/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["dynamodb:Query", "dynamodb:DeleteItem"]
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.project_name}-${var.env}-maestro-connections/index/job-channel-lookup",
      "arn:aws:dynamodb:*:*:table/${var.project_name}-${var.env}-maestro-connections/index/user-channel-lookup",
      "arn:aws:dynamodb:*:*:table/${var.project_name}-${var.env}-maestro-connections"
    ]
  }
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.fyld-brain.id]
  }
  statement {
    actions   = ["events:*"]
    resources = ["*"]
  }
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.fyld_brain_queue.arn
    ]
  }
}

resource "aws_iam_policy" "ecs_task" {
  name = "${var.project_name}-${var.env}-fyld-brain-task"

  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "task_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

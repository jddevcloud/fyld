data "template_file" "function" {
  template = file("${path.module}/iam_rotator_function.py")
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "${path.module}/.zip/iam_rotator_function.zip"
  source {
    filename = "index.py"
    content  = data.template_file.function.rendered
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-${var.env}-IAMRotator"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "IAMRotatorRolePolicy"
  role = aws_iam_role.lambda_role.id

  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "iam:ListAccessKeys",
      "iam:ListUsers",
      "iam:UpdateAccessKey",
      "iam:DeleteAccessKey",
      "iam:CreateAccessKey"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "every-day"
  description         = "Fires every day"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "check_iam_roles_every_day" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = "lambda"
  arn       = aws_lambda_function.iam_rotator.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.iam_rotator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}

resource "aws_lambda_function" "iam_rotator" {
  function_name    = "${var.project_name}-${var.env}-iam-rotator-function"
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.7"
  handler          = "index.handle"
  memory_size      = 128
  timeout          = 30
  publish          = true

  environment {
    variables = {
      SLACK_BOT_ACCESS_TOKEN = var.slack_bot_access_token
      ENVIRONMENT = var.env
    }
  }
}

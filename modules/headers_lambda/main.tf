data "template_file" "function" {
  template = file("${path.module}/headers_function.js")
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "${path.module}/.zip/headers_function.zip"
  source {
    filename = "index.js"
    content  = data.template_file.function.rendered
  }
}

data "aws_iam_policy_document" "lambda_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "default" {
  name               = "${var.project_name}-${var.env}-CloudFrontHeaderRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_role_policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "headers" {
  function_name    = "${var.project_name}-${var.env}-cloudfront-header-function"
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  role             = aws_iam_role.default.arn
  runtime          = "nodejs14.x"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 3
  publish          = true
}

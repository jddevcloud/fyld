# Invoke IAM role

data "aws_iam_policy_document" "fivetran_policy_document" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"] # TODO: Only allow invoke on fivetran lambda function
  }
}

resource "aws_iam_policy" "fivetran_policy" {
  name = "fivetran-lambda-policy"

  policy = data.aws_iam_policy_document.fivetran_policy_document.json
}

data "aws_iam_policy_document" "fivetran_assume_policy_document" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type        = "AWS"
            identifiers = ["arn:aws:iam::834469178297:root"]
        }

        condition {
            test     = "StringEquals"
            variable = "sts:ExternalId"

            values = ["variance_hunting"]
        }
    }
}

resource "aws_iam_role" "fivetran_role" {
    name                = "fivetran_lambda_role"
    path                = "/"
    assume_role_policy  = data.aws_iam_policy_document.fivetran_assume_policy_document.json
}

resource "aws_iam_role_policy_attachment" "task_policy" {
  role       = aws_iam_role.fivetran_role.name
  policy_arn = aws_iam_policy.fivetran_policy.arn
}

# Function

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_basic_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "lambda_basic_execution"
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_basic_execution_role.name
}

data "template_file" "function" {
  template = file("${path.module}/fivetran_trigger.py")
}

data "archive_file" "default" {
  type        = "zip"
  output_path = "${path.module}/.zip/fivetran_trigger.zip"
  source {
    filename = "index.py"
    content  = data.template_file.function.rendered
  }
}

resource "aws_lambda_function" "fivetran_trigger" {
  function_name    = "fivetran-trigger"
  filename         = data.archive_file.default.output_path
  source_code_hash = data.archive_file.default.output_base64sha256
  role             = aws_iam_role.lambda_basic_execution_role.arn
  runtime          = "python3.8"
  handler          = "index.handle"
  memory_size      = 128
  timeout          = 30
  publish          = true
}
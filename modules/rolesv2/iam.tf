resource "aws_iam_role" "assumed-role" {
  name = "Developer"
  max_session_duration = 28800 # 8 hours
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.identity_account_id}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "developer-admin" {
  role       = aws_iam_role.assumed-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "circleci" {
  name = "CircleCI"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.identity_account_id}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"StringEquals": {"sts:ExternalId": "circleci"}}
  }
}
EOF
}


resource "aws_iam_policy" "ci-cd-policy" {
  name        = "ci-cd-policy"
  description = "A CIRCLECI policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:RegisterTaskDefinition",
        "ecs:RunTask",
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "events:DescribeRule",
        "events:ListTargetsByRule",
        "events:PutTargets"    
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudformation:CreateChangeSet",
        "cloudformation:DeleteChangeSet",
        "cloudformation:DescribeChangeSet",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStacks",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:ListStackResources",
        "cloudformation:ValidateTemplate"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "cloudformation:CreateChangeSet",
        "cloudformation:DeleteChangeSet",
        "cloudformation:DescribeChangeSet",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStackResource",
        "cloudformation:DescribeStacks",
        "cloudformation:ExecuteChangeSet",
        "cloudformation:ListStackResources",
        "cloudformation:ValidateTemplate"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "lambda:CreateFunction",
        "lambda:GetFunction",
        "lambda:GetFunctionCodeSigningConfig",
        "lambda:ListTags",
        "lambda:ListVersionsByFunction",
        "lambda:PublishVersion",
        "lambda:UpdateFunctionCode"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:CreateGrant",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "circleci" {
  role       = aws_iam_role.circleci.name
  policy_arn = aws_iam_policy.ci-cd-policy.arn
}

resource "aws_iam_role" "terraform" {
  name = "Terraform"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.identity_account_id}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"StringEquals": {"sts:ExternalId": "terraformcloud"}}
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "read_only" {
  name = "ReadOnly"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {
      "AWS": "arn:aws:iam::${var.identity_account_id}:root"
    },
    "Action": "sts:AssumeRole",
    "Condition": {"Bool": {"aws:MultiFactorAuthPresent": "true"}}
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "read_only" {
  role       = aws_iam_role.read_only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


# API roles
data "aws_iam_policy_document" "api_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "events.amazonaws.com", "apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_role" {
  name = "${var.project_name}-${var.env}-backend"
  tags = {
    Name        = "${var.project_name}-${var.env}-backend"
    Environment = var.env
    Project     = var.project_name
  }

  assume_role_policy = data.aws_iam_policy_document.api_assume_role_policy.json
}

data "aws_iam_policy_document" "api_policy" {
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
}

resource "aws_iam_policy" "api_policy" {
  name   = "${var.project_name}-${var.env}-backend"
  path   = "/"
  policy = data.aws_iam_policy_document.api_policy.json
}

resource "aws_iam_role_policy_attachment" "api_access_attachment" {
  role       = aws_iam_role.api_role.name
  policy_arn = aws_iam_policy.api_policy.arn
}

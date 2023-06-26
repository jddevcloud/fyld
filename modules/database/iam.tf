# IAM role for RDS S3 exports

data "aws_iam_policy_document" "lambda-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "export.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds-export-role" {
  name = "RDSExportRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "rds-export-role-policy" {
  name = "RDSExportRolePolicy"
  role = aws_iam_role.rds-export-role.id

  policy = data.aws_iam_policy_document.export-role-policy.json
}

data "aws_iam_policy_document" "export-role-policy" {
  statement {
    actions = [
        "s3:PutObject*",
        "s3:ListBucket",
        "s3:GetObject*",
        "s3:DeleteObject*",
        "s3:GetBucketLocation"
    ]
    resources = [
      "${aws_s3_bucket.export.arn}/*",
      aws_s3_bucket.export.arn
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }
  
  statement {
    actions = [
      "rds:CancelExportTask",
      "rds:DescribeExportTasks",
      "rds:StartExportTask",
      "rds:DescribeDBSnapshots"
    ]
    resources = ["*"]
  }
  
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      # TODO: Remove EFS once S£ based solution is deployed
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "snowflake-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.snowflake_user_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.snowflake_external_id]
    }
  }
}

resource "aws_iam_role" "snowflake-load-role" {
  name = "SnowflakeLoadRole"

  assume_role_policy = data.aws_iam_policy_document.snowflake-assume-policy.json
}

resource "aws_iam_role_policy" "snowflake-load-role-policy" {
  name = "SnowflakeLoadRolePolicy"
  role = aws_iam_role.snowflake-load-role.id

  policy = data.aws_iam_policy_document.snowflake-load-policy.json
}

# In order to set it up on Snowflake, run:
# CREATE STORAGE INTEGRATION backend_$ENV
#   TYPE = EXTERNAL_STAGE
#   STORAGE_PROVIDER = S3
#   ENABLED = TRUE
#   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::$ACCOUNT_ID:role/SnowflakeLoadRole'
#   STORAGE_ALLOWED_LOCATIONS = ('s3://sitestream-$ENV-rds-snapshot-exports/');

# Grant permissions to Loader role
# GRANT ALL ON INTEGRATION BACKEND_DEV TO ROLE LOADER;

# Then run to get details:
# DESC INTEGRATION backend_$ENV;


data "aws_iam_policy_document" "snowflake-load-policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.export.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.export.arn]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.rds-export.arn]
  }
}

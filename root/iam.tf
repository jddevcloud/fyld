# IAM role for Snowflake access
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
# CREATE STORAGE INTEGRATION analytics_segment
#   TYPE = EXTERNAL_STAGE
#   STORAGE_PROVIDER = S3
#   ENABLED = TRUE
#   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::550158280667:role/SnowflakeLoadRole'
#   STORAGE_ALLOWED_LOCATIONS = ('s3://sitestream-root-segment-events/segment-logs/');


# Grant permissions to Loader role
# GRANT ALL ON INTEGRATION analytics_segment TO ROLE LOADER;

# Then run to get details:
# DESC INTEGRATION analytics_segment;


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
}


# IAM role for Segment logs
data "aws_iam_policy_document" "segment-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::595280932656:role/segment-s3-integration-production-access"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.segment_workspace_id]
    }
  }
}

resource "aws_iam_role" "segment-put-role" {
  name = "SegmentPutRole"

  assume_role_policy = data.aws_iam_policy_document.segment-assume-policy.json
}

resource "aws_iam_role_policy" "segment-put-role-policy" {
  name = "SegmentPutRolePolicy"
  role = aws_iam_role.segment-put-role.id

  policy = data.aws_iam_policy_document.segment-put-policy.json
}

data "aws_iam_policy_document" "segment-put-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.export.arn}/*"
    ]
  }
}

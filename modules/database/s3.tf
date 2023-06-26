# S3 bucket for snapshot exports
resource "aws_s3_bucket" "export" {
  bucket = "${var.project_name}-${var.env}-rds-snapshot-exports"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }

  lifecycle {
    ignore_changes = [versioning]
  }

  lifecycle_rule {
    id      = "all"
    enabled = true

    prefix = ""

    abort_incomplete_multipart_upload_days = 7

    expiration {
      days = 7  
    }

    noncurrent_version_expiration {
      days = 1
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-rds-snapshot-exports"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.default]
}

data "aws_iam_policy_document" "s3_policy_bucket" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-rds-snapshot-exports",
      "arn:aws:s3:::${var.project_name}-${var.env}-rds-snapshot-exports/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.export.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}

resource "aws_s3_bucket" "access_log" {
  bucket = "${var.project_name}-${var.env}-s3-access-logs"

  acl = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "auto-archive"
    enabled = true

    prefix = "/"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  tags = {
    Name        = "S3 access logs"
    Environment = var.env
  }
}

resource "aws_s3_bucket_public_access_block" "access_log" {
  bucket = aws_s3_bucket.access_log.id

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
      "arn:aws:s3:::${var.project_name}-${var.env}-s3-access-logs",
      "arn:aws:s3:::${var.project_name}-${var.env}-s3-access-logs/*"
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
  bucket = aws_s3_bucket.access_log.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}

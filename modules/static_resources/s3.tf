data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_policy_assets_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    sid       = "AllowCircleCIPut"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/circleci",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-${var.env}-backend"
      ]
    }
  }

  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket/*"
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

  statement {
    sid       = "DenyIncorrectEncryptionHeader"
    actions   = ["s3:PutObject"]
    effect    = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    actions   = ["s3:PutObject"]
    effect    = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-assets-bucket/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.s3_policy_assets_bucket.json
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.project_name}-${var.env}-assets-bucket"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 0
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Assets bucket"
    Environment = "Contains assets for the public site"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.default]
}

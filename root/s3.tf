# S3 bucket for android account configs
resource "aws_s3_bucket" "android_config" {
  bucket = "fyld-ai-android-account-config"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "fyld-ai-android-account-config"
  }
}

data "aws_iam_policy_document" "s3_policy_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.android_config.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.android_config.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::550158280667:role/Terraform"]
    }
  }

  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.android_config.arn,
      "${aws_s3_bucket.android_config.arn}/*"
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
  bucket = aws_s3_bucket.android_config.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.android_config.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket_policy.default]
}

resource "aws_s3_bucket_object" "production-config" {
  acl    = "public-read"
  bucket = aws_s3_bucket.android_config.id
  key    = "account-config-production.json"
  source = "./android/account-config-production.json"
  etag   = filemd5("./android/account-config-production.json")
}

resource "aws_s3_bucket_object" "staging-config" {
  acl    = "public-read"
  bucket = aws_s3_bucket.android_config.id
  key    = "account-config-staging.json"
  source = "./android/account-config-staging.json"
  etag   = filemd5("./android/account-config-staging.json")
}

resource "aws_s3_bucket_object" "demo-config" {
  acl    = "public-read"
  bucket = aws_s3_bucket.android_config.id
  key    = "account-config-demo.json"
  source = "./android/account-config-demo.json"
  etag   = filemd5("./android/account-config-demo.json")
}


# S3 bucket for Segment sync
resource "aws_s3_bucket" "export" {
  bucket = "sitestream-root-segment-events"
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
      days = 90
    }

    noncurrent_version_expiration {
      days = 1
    }
  }

  tags = {
    Name        = "sitestream-root-segment-events"
    Environment = "root"
    Project     = "sitestream"
  }
}

resource "aws_s3_bucket_public_access_block" "export" {
  bucket = aws_s3_bucket.export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.export]
}

data "aws_iam_policy_document" "s3_policy_export" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::sitestream-root-segment-events",
      "arn:aws:s3:::sitestream-root-segment-events/*"
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

resource "aws_s3_bucket_policy" "export" {
  bucket = aws_s3_bucket.export.id
  policy = data.aws_iam_policy_document.s3_policy_export.json
}

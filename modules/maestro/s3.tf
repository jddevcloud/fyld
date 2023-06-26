# S3 bucket for messages
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${var.env}-maestro-data-bucket"
  acl    = "private"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["HEAD", "GET", "POST", "PUT"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = var.log_bucket
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

    transition {
      days          = 60
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 14
    }
  }

  replication_configuration {
    role   = aws_iam_role.replication.arn
    rules {
      id     = "maestro_data_replication"
      status = "Enabled"
      priority = 0

      destination {
        bucket        = "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket-backup"
        storage_class = "DEEP_ARCHIVE"
        account_id    = "034199296393"
        access_control_translation {
          owner = "Destination"
        }
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-maestro-data-bucket"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.data.id

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
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/*"
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
    sid     = "AllowSSLReDenyInfectedFiles"
    actions = ["s3:GetObject"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/scan-status"
      values   = ["INFECTED"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  
  }

  statement {
    sid     = "Set replication permissions on source bucket"
    actions =[
        "s3:GetReplicationConfiguration",
        "s3:ListBucket",
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging"
    ]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }
  }

  # statement {
  #   sid       = "DenyIncorrectEncryptionHeader"
  #   actions   = ["s3:PutObject"]
  #   effect    = "Deny"
  #   resources = [
  #     "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/*"
  #   ]

  #   condition {
  #     test     = "StringNotEquals"
  #     variable = "s3:x-amz-server-side-encryption"
  #     values   = ["AES256"]
  #   }

  #   principals {
  #     type        = "*"
  #     identifiers = ["*"]
  #   }
  # }

  # statement {
  #   sid       = "DenyUnEncryptedObjectUploads"
  #   actions   = ["s3:PutObject"]
  #   effect    = "Deny"
  #   resources = [
  #     "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/*"
  #   ]

  #   condition {
  #     test     = "Null"
  #     variable = "s3:x-amz-server-side-encryption"
  #     values   = ["true"]
  #   }

  #   principals {
  #     type        = "*"
  #     identifiers = ["*"]
  #   }
  # }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.data.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}


# S3 bucket for clamav_definitions
resource "aws_s3_bucket" "clamav_definitions" {
  bucket = "${var.project_name}-${var.env}-maestro-clamav-definitions-bucket"
  acl    = "private"

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["HEAD", "GET", "POST", "PUT"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = false
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-maestro-clamav-definitions-bucket"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "clamav_definitions" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.clamav_definitions]
}

data "aws_iam_policy_document" "clamav_definitions_s3_policy_bucket" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-clamav-definitions-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-maestro-clamav-definitions-bucket/*"
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

resource "aws_s3_bucket_policy" "clamav_definitions" {
  bucket = aws_s3_bucket.clamav_definitions.id
  policy = data.aws_iam_policy_document.clamav_definitions_s3_policy_bucket.json
}

# Replication

resource "aws_iam_role" "replication" {
  name = "replication-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "tf-iam-role-policy-replication"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.data.arn}",
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket-backup"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:ObjectOwnerOverrideToBucketOwner"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.data.arn}/*",
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket-backup/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket-backup/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

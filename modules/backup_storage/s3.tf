# S3 buckets for backup
resource "aws_s3_bucket" "backup-data" {
  bucket = "sitestream-backup-data-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "all"
    enabled = true

    prefix = ""

    abort_incomplete_multipart_upload_days = 7

    transition {
      days          = 30
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      days          = 7
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  tags = {
    Name        = "sitestream-backup-data-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.backup-data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.default]
}

data "aws_iam_policy_document" "s3_policy_bucket" {
  statement {
    sid     = "AllowLambdaBackupAccess"
    actions =[
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "arn:aws:s3:::sitestream-backup-data-bucket/*",
    ]
    principals {
      type        = "AWS"
      # TODO: Update with roles from all accounts we expect backups from
      identifiers = [
        "arn:aws:iam::116977071601:role/MaestroLambdaBackupRole", # Staging
        "arn:aws:iam::734907094745:role/MaestroLambdaBackupRole", # SGN
        "arn:aws:iam::439717252254:role/MaestroLambdaBackupRole", # SME
        "arn:aws:iam::870135445827:role/MaestroLambdaBackupRole", # SME-USA
        "arn:aws:iam::459748531150:role/MaestroLambdaBackupRole" # Dev
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.backup-data.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}

# Deep archive buckets

# Dev
resource "aws_s3_bucket" "dev" {
  bucket = "sitestream-dev-maestro-data-bucket-backup"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }
}

data "aws_iam_policy_document" "dev" {
  statement {
    sid     = "Set permissions for objects"
    actions =[
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.dev.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::459748531150:role/replication-role" # Dev
      ]
    }
  }
  statement {
    sid     = "Set permissions on bucket"
    actions =[
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.dev.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::459748531150:role/replication-role" # Dev
      ]
    }
  }
  statement {
    sid     = "Allow changing ownership"
    actions =["s3:ObjectOwnerOverrideToBucketOwner"]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.dev.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "459748531150",  # Dev
        "arn:aws:iam::459748531150:role/replication-role"  # Dev
      ]
    }
  }
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.dev.arn,
      "${aws_s3_bucket.dev.arn}/*"
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

resource "aws_s3_bucket_policy" "dev" {
  bucket = aws_s3_bucket.dev.id
  policy = data.aws_iam_policy_document.dev.json
}

resource "aws_s3_bucket_public_access_block" "dev" {
  bucket = aws_s3_bucket.dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.dev]
}

# Staging
resource "aws_s3_bucket" "staging" {
  bucket = "sitestream-staging-maestro-data-bucket-backup"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }
}

data "aws_iam_policy_document" "staging" {
  statement {
    sid     = "Set permissions for objects"
    actions =[
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.staging.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::116977071601:role/replication-role" # Staging
      ]
    }
  }
  statement {
    sid     = "Set permissions on bucket"
    actions =[
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.staging.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::116977071601:role/replication-role" # Staging
      ]
    }
  }
  statement {
    sid     = "Allow changing ownership"
    actions =["s3:ObjectOwnerOverrideToBucketOwner"]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.staging.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "116977071601",  # Staging
        "arn:aws:iam::116977071601:role/replication-role" # Staging
      ]
    }
  }
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.staging.arn,
      "${aws_s3_bucket.staging.arn}/*"
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

resource "aws_s3_bucket_policy" "staging" {
  bucket = aws_s3_bucket.staging.id
  policy = data.aws_iam_policy_document.staging.json
}

resource "aws_s3_bucket_public_access_block" "staging" {
  bucket = aws_s3_bucket.staging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.staging]
}

# SGN
resource "aws_s3_bucket" "sgn" {
  bucket = "sitestream-production-maestro-data-bucket-backup"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }
}

data "aws_iam_policy_document" "sgn" {
  statement {
    sid     = "Set permissions for objects"
    actions =[
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.sgn.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::734907094745:role/replication-role" # SGN
      ]
    }
  }
  statement {
    sid     = "Set permissions on bucket"
    actions =[
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.sgn.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::734907094745:role/replication-role" # SGN
      ]
    }
  }
  statement {
    sid     = "Allow changing ownership"
    actions =[
        "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    effect  = "Allow"
    resources = ["${aws_s3_bucket.sgn.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [
        "734907094745",  # SGN
        "arn:aws:iam::734907094745:role/replication-role" # SGN
      ]
    }
  }
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.sgn.arn,
      "${aws_s3_bucket.sgn.arn}/*"
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

resource "aws_s3_bucket_policy" "sgn" {
  bucket = aws_s3_bucket.sgn.id
  policy = data.aws_iam_policy_document.sgn.json
}

resource "aws_s3_bucket_public_access_block" "sgn" {
  bucket = aws_s3_bucket.sgn.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.sgn]
}

# SME
resource "aws_s3_bucket" "sme" {
  bucket = "sitestream-sme-maestro-data-bucket-backup"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }
}

data "aws_iam_policy_document" "sme" {
  statement {
    sid     = "Set permissions for objects"
    actions =[
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.sme.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::439717252254:role/replication-role" # SME
      ]
    }
  }
  statement {
    sid     = "Set permissions on bucket"
    actions =[
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.sme.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::439717252254:role/replication-role" # SME
      ]
    }
  }
  statement {
    sid     = "Allow changing ownership"
    actions =["s3:ObjectOwnerOverrideToBucketOwner"]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.sme.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "439717252254", # SME
        "arn:aws:iam::439717252254:role/replication-role" # SME
      ]
    }
  }
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.sme.arn,
      "${aws_s3_bucket.sme.arn}/*"
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

resource "aws_s3_bucket_policy" "sme" {
  bucket = aws_s3_bucket.sme.id
  policy = data.aws_iam_policy_document.sme.json
}

resource "aws_s3_bucket_public_access_block" "sme" {
  bucket = aws_s3_bucket.sme.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.sme]
}

# SME USA
resource "aws_s3_bucket" "sme-usa" {
  bucket = "sitestream-sme-usa-maestro-data-bucket-backup"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    # Temporarily disabled due to Terraform issue.
    # https://github.com/terraform-providers/terraform-provider-aws/issues/629
    # mfa_delete = true
  }
}

data "aws_iam_policy_document" "sme-usa" {
  statement {
    sid     = "Set permissions for objects"
    actions =[
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
    ]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.sme-usa.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::870135445827:role/replication-role" # SME USA
      ]
    }
  }
  statement {
    sid     = "Set permissions on bucket"
    actions =[
        "s3:List*",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
    ]
    effect  = "Allow"
    resources = [
      aws_s3_bucket.sme-usa.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::870135445827:role/replication-role" # SME USA
      ]
    }
  }
  statement {
    sid     = "Allow changing ownership"
    actions =["s3:ObjectOwnerOverrideToBucketOwner"]
    effect  = "Allow"
    resources = [
      "${aws_s3_bucket.sme-usa.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [
        "870135445827", # SME USA
        "arn:aws:iam::870135445827:role/replication-role" # SME USA
      ]
    }
  }
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      aws_s3_bucket.sme-usa.arn,
      "${aws_s3_bucket.sme-usa.arn}/*"
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

resource "aws_s3_bucket_policy" "sme-usa" {
  bucket = aws_s3_bucket.sme-usa.id
  policy = data.aws_iam_policy_document.sme-usa.json
}

resource "aws_s3_bucket_public_access_block" "sme-usa" {
  bucket = aws_s3_bucket.sme-usa.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.sme-usa]
}
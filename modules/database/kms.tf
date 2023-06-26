# KMS key for RDS S3 exports

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms-policy" {
  statement {
    sid     = "Enable IAM User Permissions"
    actions =["kms:*"]
    effect  = "Allow"
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
  
  statement {
    sid     = "Allow use of the key"
    actions =[
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]
    effect  = "Allow"
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.rds-export-role.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Developer"
      ]
    }
  }
  
  statement {
    sid     = "Allow attachment of persistent resources"
    actions =[
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.rds-export-role.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Developer"
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }


}

resource "aws_kms_key" "rds-export" {
  description    = "KMS key for RDS S3 exports"
  policy         = data.aws_iam_policy_document.kms-policy.json
}

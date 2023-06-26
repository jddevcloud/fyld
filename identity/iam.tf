resource "aws_iam_group" "readonly" {
  name = "readonly"
}

resource "aws_iam_group_policy" "read-only-assume-role-policy" {
  name  = "read-only-assume-role-policy"
  group = aws_iam_group.readonly.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
          "arn:aws:iam::${var.ROOT_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${var.PRODUCTION_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${var.STAGING_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${var.SME_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${var.DEV_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${var.SME_USA_ACCOUNT_ID}:role/ReadOnly",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ReadOnly"
        ]
      }
  ]
}
EOF
}

resource "aws_iam_group_policy" "readonly_force_mfa" {
  name  = "readonly-force-mfa"
  group = aws_iam_group.readonly.id

  policy = data.aws_iam_policy_document.force_mfa_policy.json
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_policy" "assume-role-policy" {
  name  = "assume-role-policy"
  group = aws_iam_group.developers.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.STAGING_ACCOUNT_ID}:role/Developer"
      },
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.PRODUCTION_ACCOUNT_ID}:role/Developer"
      },
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.SME_ACCOUNT_ID}:role/Developer"
      },
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.DEV_ACCOUNT_ID}:role/Developer"
      },
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.SME_USA_ACCOUNT_ID}:role/Developer"
      }
  ]
}
EOF
}

resource "aws_iam_group" "security_audit" {
  name = "security"
}

resource "aws_iam_group_policy" "assume-security-role-policy" {
  name  = "assume-role-policy"
  group = aws_iam_group.security_audit.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.ROOT_ACCOUNT_ID}:role/SecurityAuditor"
      }
  ]
}
EOF
}

resource "aws_iam_group" "admin" {
  name = "admin"
}

resource "aws_iam_group_policy" "admin-assume-role-policy" {
  name  = "admin-assume-role-policy"
  group = aws_iam_group.admin.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::${var.ROOT_ACCOUNT_ID}:role/Admin"
      }
  ]
}
EOF
}

resource "aws_iam_group_policy" "admin_force_mfa" {
  name  = "admin-force-mfa"
  group = aws_iam_group.admin.id

  policy = data.aws_iam_policy_document.force_mfa_policy.json
}

data "aws_iam_policy_document" "force_mfa_policy" {
  statement {
    sid       = "AllowViewAccountInfo"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListVirtualMFADevices",
    ]
  }

  statement {
    sid       = "AllowManageOwnPasswords"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:ChangePassword",
      "iam:GetUser",
    ]
  }

  statement {
    sid       = "AllowManageOwnAccessKeys"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
    ]
  }

  statement {
    sid       = "AllowManageOwnSigningCertificates"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:DeleteSigningCertificate",
      "iam:ListSigningCertificates",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
    ]
  }

  statement {
    sid       = "AllowManageOwnSSHPublicKeys"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
    ]
  }

  statement {
    sid       = "AllowManageOwnGitCredentials"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteServiceSpecificCredential",
      "iam:ListServiceSpecificCredentials",
      "iam:ResetServiceSpecificCredential",
      "iam:UpdateServiceSpecificCredential",
    ]
  }

  statement {
    sid       = "AllowManageOwnVirtualMFADevice"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:mfa/$${aws:username}"]

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
  }

  statement {
    sid       = "AllowManageOwnUserMFA"
    effect    = "Allow"
    resources = ["arn:aws:iam::*:user/$${aws:username}"]

    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice",
    ]
  }

  # statement {
  #   sid       = "DenyAllExceptListedIfNoMFA"
  #   effect    = "Deny"
  #   resources = ["*"]

  #   not_actions = [
  #     "iam:CreateVirtualMFADevice",
  #     "iam:EnableMFADevice",
  #     "iam:GetUser",
  #     "iam:ListMFADevices",
  #     "iam:ListVirtualMFADevices",
  #     "iam:ResyncMFADevice",
  #     "sts:GetSessionToken",
  #   ]

  #   condition {
  #     test     = "BoolIfExists"
  #     variable = "aws:MultiFactorAuthPresent"
  #     values   = ["false"]
  #   }
  # }
}

resource "aws_iam_group_policy" "developers_force_mfa" {
  name  = "developers-force-mfa"
  group = aws_iam_group.developers.id

  policy = data.aws_iam_policy_document.force_mfa_policy.json
}

resource "aws_iam_group" "circleci" {
  name = "circleci"
}

resource "aws_iam_group_policy" "circleci-role-policy" {
  name  = "circleci-role-policy"
  group = aws_iam_group.circleci.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
          "arn:aws:iam::${var.ROOT_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${var.PRODUCTION_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${var.STAGING_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${var.SME_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${var.DEV_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${var.SME_USA_ACCOUNT_ID}:role/CircleCI",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CircleCI"
        ]
      }
  ]
}
EOF
}

resource "aws_iam_group" "terraform" {
  name = "terraform"
}

resource "aws_iam_group_policy" "terraform-role-policy" {
  name  = "terraform-role-policy"
  group = aws_iam_group.terraform.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": [
          "arn:aws:iam::${var.ROOT_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${var.PRODUCTION_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${var.STAGING_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${var.SME_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${var.DEV_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${var.SME_USA_ACCOUNT_ID}:role/Terraform",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Terraform"
        ]
      }
  ]
}
EOF
}

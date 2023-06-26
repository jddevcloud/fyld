resource "aws_iam_role" "authenticated" {
  name = "cognito_authenticated_assume_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"],
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "cognito_authenticated_policy"

  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/media/*"
      ]
    },
    {
      "Sid": "",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/thumbnails/*"
      ]
    },
    {
      "Sid": "",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/organisations/$${aws:PrincipalTag/orgUuid}/media/*"
      ]
    },
    {
      "Sid": "",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project_name}-${var.env}-maestro-data-bucket/organisations/$${aws:PrincipalTag/orgUuid}/thumbnails/*"
      ]
    }
  ]
}
EOF
}

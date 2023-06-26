resource "aws_iam_user" "circleci" {
  name = "circleci"
  path = "/"
}

resource "aws_iam_user_ssh_key" "user" {
  username   = aws_iam_user.circleci.name
  encoding   = "SSH"
  public_key = file("../ssh/circleci.pub")
}

resource "aws_iam_policy" "gitpolicy" {
  name        = "git-push-policy"
  description = "Git push policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codecommit:GitPull",
                "codecommit:GitPush"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "circleci-attach" {
  user       = aws_iam_user.circleci.name
  policy_arn = aws_iam_policy.gitpolicy.arn
}

resource "aws_codecommit_repository" "backend" {
  repository_name = "backend"
  description     = "Mirror of https://github.com/sitestream/backend"
}

resource "aws_codecommit_repository" "frontend" {
  repository_name = "frontend"
  description     = "Mirror of https://github.com/sitestream/frontend"
}

resource "aws_codecommit_repository" "android" {
  repository_name = "android"
  description     = "Mirror of https://github.com/sitestream/android"
}

resource "aws_codecommit_repository" "maestro" {
  repository_name = "maestro"
  description     = "Mirror of https://github.com/sitestream/maestro"
}

resource "aws_codecommit_repository" "infrastructure" {
  repository_name = "infrastructure"
  description     = "Mirror of https://github.com/sitestream/infrastructure"
}

resource "aws_codecommit_repository" "mobile-rn" {
  repository_name = "mobile-rn"
  description     = "Mirror of https://github.com/sitestream/mobile-rn"
}

resource "aws_codecommit_repository" "autotest-android" {
  repository_name = "autotest-android"
  description     = "Mirror of https://github.com/sitestream/autotest-android"
}

resource "aws_codecommit_repository" "dbt-warehouse" {
  repository_name = "dbt-warehouse"
  description     = "Mirror of https://github.com/sitestream/dbt-warehouse"
}

resource "aws_codecommit_repository" "data-science" {
  repository_name = "data-science"
  description     = "Mirror of https://github.com/sitestream/data-science"
}

resource "aws_codecommit_repository" "fyld-analytics" {
  repository_name = "fyld-analytics"
  description     = "Mirror of https://github.com/sitestream/fyld-analytics"
}

resource "aws_codecommit_repository" "fyld-brain" {
  repository_name = "fyld-brain"
  description     = "Mirror of https://github.com/sitestream/fyld-brain"
}

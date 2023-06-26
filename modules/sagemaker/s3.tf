# S3 bucket data science
resource "aws_s3_bucket" "data-science" {
  bucket = "${var.project_name}-${var.env}-data-science"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-data-science"
  }
}

# resource "aws_s3_bucket_public_access_block" "default" {
#   bucket = aws_s3_bucket.data-science.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

#   depends_on = [aws_s3_bucket_policy.default]
# }

# data "aws_iam_policy_document" "s3_policy_bucket" {
#   statement {
#     sid     = "AllowLambdaBackupAccess"
#     actions =[
#         "s3:GetObject",
#         "s3:PutObject",
#         "s3:PutObjectAcl"
#     ]
#     effect  = "Allow"
#     resources = [
#       "arn:aws:s3:::sitestream-backup-data-bucket/*",
#     ]
#     principals {
#       type        = "AWS"
#       # TODO: Update with roles from all accounts we expect backups from
#       identifiers = [
#         "arn:aws:iam::116977071601:role/MaestroLambdaBackupRole",
#         "arn:aws:iam::734907094745:role/MaestroLambdaBackupRole",
#         "arn:aws:iam::439717252254:role/MaestroLambdaBackupRole"
#       ]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "default" {
#   bucket = aws_s3_bucket.backup-data.id
#   policy = data.aws_iam_policy_document.s3_policy_bucket.json
# }

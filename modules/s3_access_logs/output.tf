output "log_bucket" {
  description = "The S3 bucket used for storing access logs"
  value       = aws_s3_bucket.access_log
}

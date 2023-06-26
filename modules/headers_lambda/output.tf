output "headers_lambda" {
  description = "The S3 bucket used for storing access logs"
  value       = aws_lambda_function.headers
}

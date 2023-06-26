output "iam_rotator" {
  description = "IAM rotator lambda function"
  value       = aws_lambda_function.iam_rotator
  sensitive   = true
}

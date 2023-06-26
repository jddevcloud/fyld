output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.default.id
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.default.arn
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.default.id
}

output "bootstrap_brokers" {
  description = "Plaintext connection host:port pairs"
  value       = aws_msk_cluster.snowflake_cluster.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.snowflake_cluster.bootstrap_brokers_tls
}

output "mks_security_group" {
  value = aws_security_group.mks_sg.id
}

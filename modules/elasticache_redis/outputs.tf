output "configuration_endpoint" {
  value = aws_elasticache_cluster.cluster.configuration_endpoint
}

output "port" {
  value = aws_elasticache_cluster.cluster.port
}

output "address" {
  value = aws_elasticache_cluster.cluster.cluster_address
}

output "security_group" {
  value = aws_security_group.elasticache-access.id
}

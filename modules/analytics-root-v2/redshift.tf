resource "aws_redshift_cluster" "db_instance" {
  cluster_identifier = "${var.project_name}-${var.env}-cluster"
  database_name      = "${var.project_name}_analytics"

  # Authentication
  master_username = var.username
  master_password = var.password
  snapshot_identifier = "sitestream-production-cluster-2021-04-19-01-24"
  owner_account       = "734907094745"
  encrypted           = true
  kms_key_id          = "arn:aws:kms:eu-west-1:550158280667:key/19fce7a5-b12f-44e6-be4d-b0fb37b9ada9"

  # Engine
  node_type    = "dc2.large"
  cluster_type = "single-node"

  # Networking
  publicly_accessible       = true
  port                      = 5439
  cluster_subnet_group_name = aws_redshift_subnet_group.analytics-db-subnet-group.name
  vpc_security_group_ids    = [aws_security_group.db-access.id]
  cluster_security_groups   = []

  # Backups and maintenance
  automated_snapshot_retention_period = 7
  preferred_maintenance_window        = "sun:03:00-sun:03:30"
}

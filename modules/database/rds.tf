resource "aws_db_instance" "default" {
  # Naming
  identifier = "${var.project_name}-${var.env}-${var.service}-encrypted"

  allocated_storage            = var.allocated_storage
  storage_type                 = "gp2"
  performance_insights_enabled = true

  # Engine version and cluster/DB parameter groups must remain in sync
  engine               = "postgres"
  engine_version       = var.engine_version
  instance_class       = var.encrypted_instance_type
  parameter_group_name = aws_db_parameter_group.default.name

  # Authentication
  name     = var.project_name
  username = var.username
  password = var.password

  # Networking
  port                   = 5432
  publicly_accessible    = false
  security_group_names   = []
  vpc_security_group_ids = [
    aws_security_group.rds-access.id,
    aws_security_group.elb-access.id,
    aws_security_group.bastion.id,
    # TODO: Increase SG per DB instance limit to allow >5 SGs
    aws_security_group.lambda-backup.id,
    aws_security_group.lambda-database.id,
  ]
  db_subnet_group_name   = aws_db_subnet_group.rds-db-subnet-group.name
  multi_az               = var.multi_az

  # Backups and maintenance
  allow_major_version_upgrade = true
  backup_retention_period     = var.backup_retention_period
  backup_window               = "02:30-03:00"
  maintenance_window          = "sun:03:00-sun:03:30"
  storage_encrypted           = true
  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}

resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = var.db_parameter_group_family

  # Sets the maximum allowed duration of any statement.
  # Set it to 60 seconds
  parameter {
    name  = "statement_timeout"
    value = "60000"
  }

  # Settings for pgBadger
  # Log all statements longer than 1 second
  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }
  parameter {
    name         = "log_checkpoints"
    value        = "1"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "log_connections"
    value = "0"
  }
  parameter {
    name  = "log_disconnections"
    value = "0"
  }
  parameter {
    name  = "log_lock_waits"
    value = "1"
  }
  parameter {
    name  = "log_temp_files"
    value = "1000"
  }
  parameter {
    name  = "log_autovacuum_min_duration"
    value = "1000"
  }
  parameter {
    name  = "rds.logical_replication"
    value = "1"
    apply_method = "pending-reboot"
  }
}
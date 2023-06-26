resource "aws_db_subnet_group" "rds-db-subnet-group" {
  name        = "rds-db-${var.env}"
  description = "rds-db-${var.env}"
  subnet_ids  = var.db_subnets
}

resource "aws_redshift_subnet_group" "analytics-db-subnet-group" {
  name        = "analytics-db-${var.env}"
  description = "analytics-db-${var.env}"
  subnet_ids  = aws_subnet.public.*.id
}

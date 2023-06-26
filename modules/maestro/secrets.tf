resource "aws_secretsmanager_secret" "maestro" {
  name = "${var.project_name}-${var.env}-maestro"
}

resource "aws_secretsmanager_secret" "backend" {
  name = "${var.project_name}-${var.env}-backend-ecs"
}

resource "aws_secretsmanager_secret" "fyld-brain" {
  name = "${var.project_name}-${var.env}-fyld-brain-ecs"
}

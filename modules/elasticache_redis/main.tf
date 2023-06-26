resource "aws_elasticache_subnet_group" "subnet-group" {
  name       = "${var.project_name}-${var.env}-redis"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "cache-params-redis"
  family = "redis7"

}

resource "aws_elasticache_cluster" "cluster" {
  cluster_id           = "${var.project_name}-${var.env}-redis"
  engine               = "redis"
  node_type            = var.size
  num_cache_nodes      = var.nodes
  parameter_group_name = aws_elasticache_parameter_group.default.name
  port                 = var.port
  subnet_group_name    = aws_elasticache_subnet_group.subnet-group.name
  security_group_ids   = [aws_security_group.elasticache-access.id]
  az_mode              = var.nodes > 1 ? "cross-az" : "single-az"
  maintenance_window   = "sun:02:00-sun:03:00"
}


resource "aws_security_group" "elasticache-access" {
  name        = "elasticache-access-${var.env}-redis"
  description = "Ingress to elasticache from lambda"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.security_groups
    self            = false
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
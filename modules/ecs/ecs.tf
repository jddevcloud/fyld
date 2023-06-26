resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.env}"
}

resource "aws_ecs_service" "main" {
  name                               = "${var.project_name}-${var.env}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.ecs_task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  launch_type                        = "EC2"
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  network_configuration {
    security_groups = [aws_security_group.task.id, var.database_security_group, var.elastiache_security_group]
    subnets         = var.protected_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.project_name}-api"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.https, aws_lb_target_group.main]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }

  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

}

resource "aws_cloudwatch_log_group" "ecs-log" {
  name               = "/ecs/${var.project_name}-api"
  retention_in_days  = 1827 # 5 years
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2", "FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.project_name}-api",
      "image": "${var.repository_url}:latest",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "mountPoints": [],
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port},
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "DJANGO_SETTINGS_MODULE",
          "value": "sitestream.settings.${var.env}"
        },
        {
          "name": "AWS_SSM_NAMESPACE",
          "value": "${aws_secretsmanager_secret.backend.id}"
        },
        {
          "name": "AWS_DEFAULT_REGION",
          "value": "${var.region}"
        }
      ],
      "logConfiguration": { 
        "logDriver": "awslogs",
        "options": { 
            "awslogs-group" : "${aws_cloudwatch_log_group.ecs-log.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "ecs"
        }
      },
      "volumesFrom": []
    }
  ]
DEFINITION
}

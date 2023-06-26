resource "aws_ecs_cluster" "fyld-brain" {
  name = "${var.project_name}-${var.env}-fyld-brain"
}

resource "aws_ecs_service" "fyld-brain" {
  name                               = "${var.project_name}-${var.env}-fyld-brain"
  cluster                            = aws_ecs_cluster.fyld-brain.id
  task_definition                    = aws_ecs_task_definition.fyld-brain.arn
  desired_count                      = var.ecs_task_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  network_configuration {
    security_groups = [var.database_security_group, var.elastiache_security_group]
    subnets         = var.protected_subnets
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

}

resource "aws_ecs_service" "fyld-brain-fallback" {
  name                               = "${var.project_name}-${var.env}-fyld-brain-fallback"
  cluster                            = aws_ecs_cluster.fyld-brain.id
  task_definition                    = aws_ecs_task_definition.fyld-brain.arn
  desired_count                      = 0
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  network_configuration {
    security_groups = [var.database_security_group, var.elastiache_security_group]
    subnets         = var.protected_subnets
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  capacity_provider_strategy {
    capacity_provider = var.fallback_capacity_provider
    weight            = 100
  }

}

resource "aws_cloudwatch_log_group" "ecs-log" {
  name               = "/ecs/${var.project_name}-fyld-brain"
  retention_in_days  = 1827 # 5 years
}

resource "aws_ecs_task_definition" "fyld-brain" {
  family                   = "${var.project_name}-${var.env}-fyld-brain"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "${var.project_name}-fyld-brain",
      "image": "${var.repository_url}:latest",
      "cpu": ${var.cpu},
      "memory": ${var.memory},
      "essential": true,
      "mountPoints": [],
      "environment": [
        {
          "name": "AWS_SSM_NAMESPACE",
          "value": "${aws_secretsmanager_secret.fyld-brain.id}"
        },
        {
          "name": "AWS_DEFAULT_REGION",
          "value": "${var.region}"
        },
        {
          "name": "SQS_EVENT_BUS_NAME",
          "value": "${aws_sqs_queue.fyld_brain_queue.name}"
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

  ephemeral_storage {
    size_in_gib = 50
  }
}

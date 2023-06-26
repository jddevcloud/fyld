resource "aws_iam_role" "ecs_events" {
  name = "ecs_events"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = aws_iam_role.ecs_events.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "${replace(aws_ecs_task_definition.main.arn, "/:\\d+$/", ":*")}"
        }
    ]
}
DOC
}

resource "aws_cloudwatch_event_rule" "every_5_mins" {
  name                = "run-scheduled-task-every-5-minutes"
  description         = "Runs tasks every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_rule" "every_day" {
  name                = "run-scheduled-task-every-day"
  description         = "Runs tasks every day"
  schedule_expression = "rate(1 day)"
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.main.family
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "run-scheduled-task-every-5-minutes"
  arn       = aws_ecs_cluster.main.arn
  rule      = aws_cloudwatch_event_rule.every_5_mins.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = replace(aws_ecs_task_definition.main.arn, "/:\\d+$/", ":${max(aws_ecs_task_definition.main.revision, data.aws_ecs_task_definition.main.revision)}")

    network_configuration {
      security_groups  = [aws_security_group.task.id, var.database_security_group, var.elastiache_security_group]
      subnets          = var.protected_subnets
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "${var.project_name}-api",
      "command": ["python", "manage.py", "runjobs", "minutely"]
    }
  ]
}
DOC
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task_daily" {
  target_id = "run-scheduled-task-every-day"
  arn       = aws_ecs_cluster.main.arn
  rule      = aws_cloudwatch_event_rule.every_day.name
  role_arn  = aws_iam_role.ecs_events.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = replace(aws_ecs_task_definition.main.arn, "/:\\d+$/", ":${max(aws_ecs_task_definition.main.revision, data.aws_ecs_task_definition.main.revision)}")

    network_configuration {
      security_groups  = [aws_security_group.task.id, var.database_security_group, var.elastiache_security_group]
      subnets          = var.protected_subnets
    }
  }

  input = <<DOC
{
  "containerOverrides": [
    {
      "name": "${var.project_name}-api",
      "command": ["python", "manage.py", "runjobs", "daily"]
    }
  ]
}
DOC
}
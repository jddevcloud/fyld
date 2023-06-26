resource "aws_autoscaling_group" "main" {
  name                        = "ecs-autoscaling-group"
  max_size                    = var.ecs_instance_max_size
  min_size                    = var.ecs_instance_min_size
  desired_capacity            = var.ecs_instance_desired_capacity
  vpc_zone_identifier         = var.protected_subnets
  health_check_type           = "ELB"
  protect_from_scale_in       = false

  launch_template {
    id      = aws_launch_template.ecs-launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${aws_ecs_cluster.main.name}-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.ecs-launch-template]
}

resource "aws_ecs_capacity_provider" "main" {
  name = "main"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.main.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 3
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.ecs_scaling_target_capacity
    }
  }
}

resource "aws_appautoscaling_target" "main_target" {
  max_capacity       = var.ecs_scaling_max_capacity
  min_capacity       = var.ecs_scaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.main]
}

resource "aws_appautoscaling_policy" "main" {
  name               = "${var.project_name}-${var.env}-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main_target.resource_id
  scalable_dimension = aws_appautoscaling_target.main_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 20

    scale_in_cooldown  = 300
    scale_out_cooldown = 120

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.main_target]
}

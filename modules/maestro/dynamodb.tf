resource "aws_dynamodb_table" "connections" {
  name           = "${var.project_name}-${var.env}-maestro-connections"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_connections_read_capacity
  write_capacity = var.dynamodb_connections_write_capacity
  hash_key       = "connectionId"
  range_key      = "jobId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  attribute {
    name = "jobId"
    type = "S"
  }

  attribute {
    name = "cognitoId"
    type = "S"
  }

  # TODO: Delete with next deployment
  global_secondary_index {
    name            = "job-channel-lookup"
    hash_key        = "jobId"
    range_key       = "connectionId"
    read_capacity   = var.dynamodb_connections_secondary_read_capacity
    write_capacity  = var.dynamodb_connections_secondary_write_capacity
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "user-channel-lookup"
    hash_key        = "cognitoId"
    read_capacity   = var.dynamodb_connections_secondary_read_capacity
    write_capacity  = var.dynamodb_connections_secondary_write_capacity
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-maestro-connections"
    Environment = var.env
    Project     = var.project_name
  }
}


resource "aws_appautoscaling_target" "aws_dynamodb_table_index_job_channel_lookup_read_target" {
  max_capacity       = var.appautoscaling_target_read_connections_indexes_max_capacity
  min_capacity       = var.appautoscaling_target_read_connections_indexes_min_capacity
  resource_id        = "table/${aws_dynamodb_table.connections.name}/index/job-channel-lookup"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "aws_dynamodb_table_index_job_channel_lookup_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.aws_dynamodb_table_index_job_channel_lookup_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.aws_dynamodb_table_index_job_channel_lookup_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.aws_dynamodb_table_index_job_channel_lookup_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.aws_dynamodb_table_index_job_channel_lookup_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 55  #set utilization to 55%
  }
}


resource "aws_appautoscaling_target" "aws_dynamodb_table_index_user_channel_lookup_read_target" {
  max_capacity       = var.appautoscaling_target_read_connections_indexes_max_capacity
  min_capacity       = var.appautoscaling_target_read_connections_indexes_min_capacity
  resource_id        = "table/${aws_dynamodb_table.connections.name}/index/user-channel-lookup"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "aws_dynamodb_table_index_user_channel_lookup_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.aws_dynamodb_table_index_user_channel_lookup_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.aws_dynamodb_table_index_user_channel_lookup_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.aws_dynamodb_table_index_user_channel_lookup_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.aws_dynamodb_table_index_user_channel_lookup_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 55  #set utilization to 55%
  }
}



resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  max_capacity       = var.appautoscaling_target_read_connections_max_capacity
  min_capacity       = var.appautoscaling_target_read_connections_min_capacity
  resource_id        = "table/${aws_dynamodb_table.connections.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 55  #set utilization to 55%
  }
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  max_capacity       = var.appautoscaling_target_write_connections_max_capacity
  min_capacity       = var.appautoscaling_target_write_connections_min_capacity
  resource_id        = "table/${aws_dynamodb_table.connections.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.dynamodb_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 55  #set utilization to 55%
  }
}

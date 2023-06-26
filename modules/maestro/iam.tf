resource "aws_iam_role" "thumbnailer-role" {
  name = "MaestroThumbnailerRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

data "aws_iam_policy_document" "lambda-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "thumbnailer-role-policy" {
  name = "MaestroThumbnailerRolePolicy"
  role = aws_iam_role.thumbnailer-role.id

  policy = data.aws_iam_policy_document.thumbnailer-policy.json
}

data "aws_iam_policy_document" "thumbnailer-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*",
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "transcribe-role" {
  name = "MaestroTranscribeRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "transcribe-role-policy" {
  name = "MaestroTranscribeRolePolicy"
  role = aws_iam_role.transcribe-role.id

  policy = data.aws_iam_policy_document.transcribe-policy.json
}

data "aws_iam_policy_document" "transcribe-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*",
    ]
  }

  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      var.fyld_brain_sqs_queue_arn
    ]
  }

  statement {
    actions = [
      "transcribe:*",
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "save-transcription-role" {
  name = "MaestroSaveTranscriptionRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "save-transcription-role-policy" {
  name = "MaestroSaveTranscriptionRolePolicy"
  role = aws_iam_role.save-transcription-role.id

  policy = data.aws_iam_policy_document.save-transcription-policy.json
}

data "aws_iam_policy_document" "save-transcription-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*",
    ]
  }

  statement {
    actions = [
      "events:*",
      "transcribe:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "connection-role" {
  name = "MaestroConnectionRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "connection-role-policy" {
  name = "MaestroConnectionRolePolicy"
  role = aws_iam_role.connection-role.id

  policy = data.aws_iam_policy_document.connection-policy.json
}

data "aws_iam_policy_document" "connection-policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query"
    ]
    resources = [
      aws_dynamodb_table.connections.arn
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "publisher-role" {
  name = "MaestroPublisherRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "publisher-role-policy" {
  name = "MaestroPublisherRolePolicy"
  role = aws_iam_role.publisher-role.id

  policy = data.aws_iam_policy_document.publisher-policy.json
}

data "aws_iam_policy_document" "publisher-policy" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.event_bus.arn
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "orchestrator-role" {
  name = "MaestroOrchestratorRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "orchestrator-role-policy" {
  name = "MaestroOrchestratorRolePolicy"
  role = aws_iam_role.orchestrator-role.id

  policy = data.aws_iam_policy_document.orchestrator-policy.json
}

data "aws_iam_policy_document" "orchestrator-policy" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      aws_sqs_queue.event_bus.arn
    ]
  }

  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      "arn:aws:lambda:${var.region}:*:function:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "broadcaster-role" {
  name = "MaestroBroadcasterRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "broadcaster-role-policy" {
  name = "MaestroBroadcasterRolePolicy"
  role = aws_iam_role.broadcaster-role.id

  policy = data.aws_iam_policy_document.broadcaster-policy.json
}

data "aws_iam_policy_document" "broadcaster-policy" {
  statement {
    actions = [
      "dynamodb:Query"
    ]
    resources = [
      "${aws_dynamodb_table.connections.arn}/index/job-channel-lookup",
      "${aws_dynamodb_table.connections.arn}/index/user-channel-lookup"
    ]
  }

  statement {
    actions = [
      "execute-api:ManageConnections"
    ]
    resources = [
      "arn:aws:execute-api:${var.region}:*:**/@connections/*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "authorizer-role" {
  name = "MaestroAuthorizerRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-api-gateway-assume-policy.json
}

data "aws_iam_policy_document" "lambda-api-gateway-assume-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "authorizer-role-policy" {
  name = "MaestroAuthorizerRolePolicy"
  role = aws_iam_role.authorizer-role.id

  policy = data.aws_iam_policy_document.authorizer-policy.json
}

data "aws_iam_policy_document" "authorizer-policy" {
  statement {
    actions = [
      "cognito-idp:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "cognito-event-handler-role" {
  name = "MaestroCognitoEventHandlerRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "cognito-event-handler-role-policy" {
  name = "MaestroMaestroCognitoEventHandlerRolePolicy"
  role = aws_iam_role.cognito-event-handler-role.id

  policy = data.aws_iam_policy_document.cognito-event-handler-policy.json
}

data "aws_iam_policy_document" "cognito-event-handler-policy" {
  statement {
    actions = [
      "cognito-idp:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "predict-role" {
  name = "MaestroPredictRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "predict-role-policy" {
  name = "MaestroPredictRolePolicy"
  role = aws_iam_role.predict-role.id

  policy = data.aws_iam_policy_document.predict-policy.json
}

data "aws_iam_policy_document" "predict-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "update-models-role" {
  name = "MaestroUpdateModelsRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "update-models-role-policy" {
  name = "MaestroUpdateModelsRolePolicy"
  role = aws_iam_role.update-models-role.id

  policy = data.aws_iam_policy_document.update-models-policy.json
}

data "aws_iam_policy_document" "update-models-policy" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*"
    ]
  }

  statement {
    actions = [
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_role" "lambda-backup-role" {
  name = "MaestroLambdaBackupRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "lambda-backup-role-policy" {
  name = "MaestroLambdaBackupRolePolicy"
  role = aws_iam_role.lambda-backup-role.id

  policy = data.aws_iam_policy_document.lambda-backup-policy.json
}

data "aws_iam_policy_document" "lambda-backup-policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*",
      aws_s3_bucket.data.arn
    ]
  }

  statement {
    actions = [
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::sitestream-backup-data-bucket/*",
    ]
  }
}

resource "aws_iam_role" "lambda-clamav-role" {
  name = "MaestroLambdaClamAVRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "lambda-clamav-role-policy" {
  name = "MaestroLambdaClamAVRolePolicy"
  role = aws_iam_role.lambda-clamav-role.id

  policy = data.aws_iam_policy_document.lambda-clamav-policy.json
}

data "aws_iam_policy_document" "lambda-clamav-policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*",
      aws_s3_bucket.data.arn
    ]
  }

  statement {
    actions = [
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:DescribeMountTargets"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${aws_s3_bucket.data.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.clamav_definitions.arn}/*",
      aws_s3_bucket.clamav_definitions.arn
    ]
  }

}

resource "aws_iam_role" "lambda-notebook-runner-role" {
  name = "MaestroNotebookRunnerRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "lambda-notebook-runner-role-policy" {
  name = "MaestroLambdaNotebookRunnerRolePolicy"
  role = aws_iam_role.lambda-notebook-runner-role.id

  policy = data.aws_iam_policy_document.lambda-notebook-runner-policy.json
}

data "aws_iam_policy_document" "lambda-notebook-runner-policy" {
  statement {
    actions = [
      "events:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "lambda-auth-verify-role" {
  name = "MaestroLambdaAuthVerifyRole"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "lambda-auth-verify-role-policy" {
  name = "MaestroLambdaAuthVerifyRolePolicy"
  role = aws_iam_role.lambda-auth-verify-role.id
  policy = data.aws_iam_policy_document.lambda-auth-verify-policy.json
}

data "aws_iam_policy_document" "lambda-auth-verify-policy" {
  statement {
    actions = [
      "cognito-idp:AdminUpdateUserAttributes"
    ]
    resources = [
      "arn:aws:cognito-idp:${var.region}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito_user_pool_id}"
    ]
  }
}


resource "aws_iam_role" "accuweather-role" {
  name = "MaestroAccuweatherRole"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-policy.json
}

resource "aws_iam_role_policy" "accuweather-role-policy" {
  name = "MaestroAccuweatherRolePolicy"
  role = aws_iam_role.accuweather-role.id

  policy = data.aws_iam_policy_document.accuweather-policy.json
}

data "aws_iam_policy_document" "accuweather-policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.maestro.id
    ]
  }

  statement {
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = [
      "*"
    ]
  }
}
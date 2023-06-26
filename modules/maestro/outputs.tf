resource "aws_cloudformation_stack" "terraform_outputs" {
  name = "terraform-maestro-outputs-stack"

  template_body = <<STACK
{
  "Resources": {
    "CognitoPoolId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "cognito-pool-id",
        "Type": "String",
        "Value": "${var.cognito_user_pool_id}"
      }
    },
    "CognitoAppClientId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "cognito-app-client-id",
        "Type": "String",
        "Value": "${var.cognito_user_pool_client_id}"
      }
    },
    "MaestroDataBucketName": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-data-bucket-name",
        "Type": "String",
        "Value": "${aws_s3_bucket.data.bucket}"
      }
    },
    "MaestroClamAVDefinitionsBucketName": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-vlamav-definitions-bucket-name",
        "Type": "String",
        "Value": "${aws_s3_bucket.clamav_definitions.bucket}"
      }
    },
    "MaestroEventsQueue": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-events-queue",
        "Type": "String",
        "Value": "${aws_sqs_queue.event_bus.arn}"
      }
    },
    "MaestroEventsQueueId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-events-queue-id",
        "Type": "String",
        "Value": "${aws_sqs_queue.event_bus.id}"
      }
    },
    "MaestroLambdaTranscribeRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-transcribe-role",
        "Type": "String",
        "Value": "${aws_iam_role.transcribe-role.arn}"
      }
    },
    "MaestroLambdaSaveTranscriptionRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-save-transcription-role",
        "Type": "String",
        "Value": "${aws_iam_role.save-transcription-role.arn}"
      }
    },
    "MaestroLambdaConnectionRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-connection-role",
        "Type": "String",
        "Value": "${aws_iam_role.connection-role.arn}"
      }
    },
    "MaestroLambdaPublisherRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-publisher-role",
        "Type": "String",
        "Value": "${aws_iam_role.publisher-role.arn}"
      }
    },
    "MaestroLambdaOrchestratorRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-orchestrator-role",
        "Type": "String",
        "Value": "${aws_iam_role.orchestrator-role.arn}"
      }
    },
    "MaestroLambdaBroadcasterRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-broadcaster-role",
        "Type": "String",
        "Value": "${aws_iam_role.broadcaster-role.arn}"
      }
    },
    "MaestroAuthorizerRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-authorizer-role",
        "Type": "String",
        "Value": "${aws_iam_role.authorizer-role.arn}"
      }
    },
    "MaestroCognitoEventHandlerRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-cognito-event-handler-role",
        "Type": "String",
        "Value": "${aws_iam_role.cognito-event-handler-role.arn}"
      }
    },
    "MaestroPredictRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-predict-role",
        "Type": "String",
        "Value": "${aws_iam_role.predict-role.arn}"
      }
    },
    "MaestroAccuweatherRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-accuweather-role",
        "Type": "String",
        "Value": "${aws_iam_role.accuweather-role.arn}"
      }
    },
    "MaestroUpdateModelsRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-update-models-role",
        "Type": "String",
        "Value": "${aws_iam_role.update-models-role.arn}"
      }
    },
    "MaestroLambdaThumbnailerRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-thumbnailer-role",
        "Type": "String",
        "Value": "${aws_iam_role.thumbnailer-role.arn}"
      }
    },
    "MaestroLambdaBackupRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-backup-role",
        "Type": "String",
        "Value": "${aws_iam_role.lambda-backup-role.arn}"
      }
    },
    "MaestroLambdaClamAVRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-clamav-role",
        "Type": "String",
        "Value": "${aws_iam_role.lambda-clamav-role.arn}"
      }
    },
    "MaestroLambdaNotebookRunnerRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-notebook-runner-role",
        "Type": "String",
        "Value": "${aws_iam_role.lambda-notebook-runner-role.arn}"
      }
    },
    "MaestroLambdaAuthVerifyRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "maestro-lambda-auth-verify-role",
        "Type": "String",
        "Value": "${aws_iam_role.lambda-auth-verify-role.arn}"
      }
    },
    "ProtectedSubnetMapping": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "protected-subnet-mapping",
        "Type": "String",
        "Value": "${join(", ", var.protected_subnet_ids.*)}"
      }
    },
    "LambdaBackupSGId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "lambda-backup-sg-id",
        "Type": "String",
        "Value": "${var.backup_security_group_id}"
      }
    },
    "LambdaClamAVSGId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "lambda-clamav-sg-id",
        "Type": "String",
        "Value": "${var.lambda_clamav_security_group_id}"
      }
    },
    "LambdaDatabaseAccessSGId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "lambda-database-access-sg-id",
        "Type": "String",
        "Value": "${var.lambda_database_access_security_group_id}"
      }
    },
    "EFSAccessPoint": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "efs-access-point",
        "Type": "String",
        "Value": "${aws_efs_access_point.lambda-backup-access-point.arn}"
      }
    },
    "EFSClamAVAccessPoint": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "efs-clamav-access-point",
        "Type": "String",
        "Value": "${aws_efs_access_point.clamav-access-point.arn}"
      }
    }
  },
  "Outputs": {
    "CognitoPoolId": {
      "Value": "${var.cognito_user_pool_id}"
    },
    "CognitoAppClientId": {
      "Value": "${var.cognito_user_pool_client_id}"
    },
    "MaestroDataBucketName": {
      "Value": "${aws_s3_bucket.data.bucket}"
    },
    "MaestroClamAVDefinitionsBucketName": {
      "Value": "${aws_s3_bucket.clamav_definitions.bucket}"
    },
    "MaestroEventsQueue": {
        "Value": "${aws_sqs_queue.event_bus.arn}"
    },
    "MaestroEventsQueueId": {
        "Value": "${aws_sqs_queue.event_bus.id}"
    },
    "MaestroLambdaTranscribeRole": {
        "Value": "${aws_iam_role.transcribe-role.arn}"
    },
    "MaestroLambdaSaveTranscriptionRole": {
        "Value": "${aws_iam_role.save-transcription-role.arn}"
    },
    "MaestroLambdaConnectionRole": {
        "Value": "${aws_iam_role.connection-role.arn}"
    },
    "MaestroLambdaPublisherRole": {
        "Value": "${aws_iam_role.publisher-role.arn}"
    },
    "MaestroLambdaOrchestratorRole": {
        "Value": "${aws_iam_role.orchestrator-role.arn}"
    },
    "MaestroLambdaBroadcasterRole": {
        "Value": "${aws_iam_role.broadcaster-role.arn}"
    },
    "MaestroAuthorizerRole": {
        "Value": "${aws_iam_role.authorizer-role.arn}"
    },
    "MaestroCognitoEventHandlerRole": {
        "Value": "${aws_iam_role.cognito-event-handler-role.arn}"
    },
    "MaestroPredictRole": {
        "Value": "${aws_iam_role.predict-role.arn}"
    },
    "MaestroAccuweatherRole": {
        "Value": "${aws_iam_role.accuweather-role.arn}"
    },
    "MaestroUpdateModelsRole": {
        "Value": "${aws_iam_role.update-models-role.arn}"
    },
    "MaestroLambdaThumbnailerRole": {
        "Value": "${aws_iam_role.thumbnailer-role.arn}"
    },
    "MaestroLambdaBackupRole": {
        "Value": "${aws_iam_role.lambda-backup-role.arn}"
    },
    "MaestroLambdaClamAVRole": {
        "Value": "${aws_iam_role.lambda-clamav-role.arn}"
    },
    "MaestroLambdaNotebookRunnerRole": {
        "Value": "${aws_iam_role.lambda-notebook-runner-role.arn}"
    },
    "MaestroLambdaAuthVerifyRole": {
        "Value": "${aws_iam_role.lambda-auth-verify-role.arn}"
    },
    "ProtectedSubnetMapping": {
        "Value": "${join(", ", var.protected_subnet_ids.*)}"
    },
    "LambdaBackupSGId": {
        "Value": "${var.backup_security_group_id}"
    },
    "LambdaClamAVSGId": {
        "Value": "${var.lambda_clamav_security_group_id}"
    },
    "LambdaDatabaseAccessSGId": {
        "Value": "${var.lambda_database_access_security_group_id}"
    },
    "EFSAccessPoint": {
      "Value": "${aws_efs_access_point.lambda-backup-access-point.arn}"
    },
    "EFSClamAVAccessPoint": {
      "Value": "${aws_efs_access_point.clamav-access-point.arn}"
    }
  }
}
STACK
}

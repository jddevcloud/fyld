output "elb_security_group" {
  value = aws_security_group.elb-access.id
}

output "bastion_security_group" {
  value = aws_security_group.bastion.id
}

output "lambda_backup_security_group" {
  value = aws_security_group.lambda-backup.id
}

output "lambda_database_access_security_group" {
  value = aws_security_group.lambda-database.id
}

output "lambda_clamav_security_group" {
  value = aws_security_group.lambda-clamav.id
}

output "rds_access_security_group" {
  value = aws_security_group.rds-access.id
}

resource "aws_cloudformation_stack" "terraform_outputs" {
  name = "terraform-rds-outputs"

  template_body = <<STACK
{
  "Resources": {
    "RdsSnapshotExportsDataBucketName": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "rds-snapshot-exports-bucket-name",
        "Type": "String",
        "Value": "${aws_s3_bucket.export.bucket}"
      }
    },
    "RdsExportRole": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "rds-export-role",
        "Type": "String",
        "Value": "${aws_iam_role.rds-export-role.arn}"
      }
    },
    "RdsExportKey": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "rds-export-key",
        "Type": "String",
        "Value": "${aws_kms_key.rds-export.arn}"
      }
    }
  },
  "Outputs": {
    "RdsSnapshotExportsDataBucketName": {
      "Value": "${aws_s3_bucket.export.bucket}"
    },
    "RdsExportRole": {
      "Value": "${aws_iam_role.rds-export-role.arn}"
    },
    "RdsExportKey": {
        "Value": "${aws_kms_key.rds-export.arn}"
    }
  }
}
STACK
}

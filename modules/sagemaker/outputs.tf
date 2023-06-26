resource "aws_cloudformation_stack" "terraform_outputs" {
  name = "terraform-sagemaker-outputs-stack"

  template_body = <<STACK
{
  "Resources": {
    "DataScienceBucketName": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "data-science-bucket-name",
        "Type": "String",
        "Value": "${aws_s3_bucket.data-science.bucket}"
      }
    }
  },
  "Outputs": {
    "MaestroDataBucketName": {
      "Value": "${aws_s3_bucket.data-science.bucket}"
    }
  }
}
STACK
}

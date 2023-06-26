resource "aws_cloudformation_stack" "terraform_outputs" {
  name = "terraform-fyld-brain-outputs-stack"

  template_body = <<STACK
{
  "Resources": {
    "FyldBrainEventsQueue": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "fyld-brain-events-queue",
        "Type": "String",
        "Value": "${aws_sqs_queue.fyld_brain_queue.arn}"
      }
    },
    "FyldBrainEventsQueueId": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "fyld-brain-events-queue-id",
        "Type": "String",
        "Value": "${aws_sqs_queue.fyld_brain_queue.id}"
      }
    },
    "FyldBrainEventsQueueName": {
      "Type": "AWS::SSM::Parameter",
      "Properties": {
        "Name": "fyld-brain-events-queue-name",
        "Type": "String",
        "Value": "${aws_sqs_queue.fyld_brain_queue.name}"
      }
    }
  },
  "Outputs": {
    "FyldBrainEventsQueue": {
        "Value": "${aws_sqs_queue.fyld_brain_queue.arn}"
    },
    "FyldBrainEventsQueueId": {
        "Value": "${aws_sqs_queue.fyld_brain_queue.id}"
    },
    "FyldBrainEventsQueueName": {
      "Value": "${aws_sqs_queue.fyld_brain_queue.name}"
    }
  }
}
STACK
}

output "fyld_brain_sqs_queue_arn" {
  value = aws_sqs_queue.fyld_brain_queue.arn
}
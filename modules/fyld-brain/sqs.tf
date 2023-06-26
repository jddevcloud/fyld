data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "fyld_brain_queue_policy" {
  statement {
    effect    = "Allow"
    actions   = ["SQS:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_sqs_queue" "fyld_brain_dlq" {
  name              = "FyldBrainDeadLetters"
  kms_master_key_id = "alias/aws/sqs"
}

resource "aws_sqs_queue_policy" "fyld_brain_dlq_policy" {
  queue_url = aws_sqs_queue.fyld_brain_dlq.id
  policy    = data.aws_iam_policy_document.fyld_brain_queue_policy.json
}

resource "aws_sqs_queue" "fyld_brain_queue" {
  name                       = "${var.project_name}-${var.env}-fyld-brain-event-bus"
  visibility_timeout_seconds = 350
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.fyld_brain_dlq.arn}\",\"maxReceiveCount\":4}"
  policy                     = data.aws_iam_policy_document.fyld_brain_queue_policy.json
  kms_master_key_id          = "alias/aws/sqs"

  tags = {
    Name        = "${var.project_name}-${var.env}-fyld-brain-event-bus"
    Environment = var.env
    Project     = var.project_name
  }
}

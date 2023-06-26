# SageMaker Common
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

# Managed AWS policies
data "aws_iam_policy" "AmazonSageMakerFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

data "aws_iam_policy" "AmazonAugmentedAIFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonAugmentedAIFullAccess"
}

data "aws_iam_policy" "AmazonTranscribeFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess"
}

data "aws_iam_policy" "AmazonRekognitionFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess"
}

# Custom policy
data "aws_iam_policy_document" "sagemaker_policy" {
  statement {
    actions   = [
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketTagging",
      "s3:GetObjectVersionTagging",
      "s3:ListBucketVersions",
      "s3:GetObjectAttributes",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketAcl",
      "s3:GetObjectVersionAttributes",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutObjectVersionAcl",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectTagging",
      "s3:PutObjectAcl",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
  }

  statement {
    actions   = [
      "logs:StartQuery",
      "logs:GetQueryResults",
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.data-science.arn}/*",
      aws_s3_bucket.data-science.arn
    ]
  }

  depends_on = [aws_s3_bucket.data-science]
}

resource "aws_iam_policy" "sagemaker_policy" {
  name = "${var.project_name}-${var.env}-sagemaker-policy"

  policy = data.aws_iam_policy_document.sagemaker_policy.json
}

# Role
resource "aws_iam_role" "sagemaker_role" {
  name               = "${var.project_name}-${var.env}-sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Role attachments
resource "aws_iam_role_policy_attachment" "sagemaker_role_managed_policy" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = data.aws_iam_policy.AmazonSageMakerFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_managed_policy_ai" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = data.aws_iam_policy.AmazonAugmentedAIFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_managed_policy_transcribe" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = data.aws_iam_policy.AmazonTranscribeFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_managed_policy_rekognition" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = data.aws_iam_policy.AmazonRekognitionFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "sagemaker_role_custom_policy" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_policy.arn
}



# Transcribe service policy
data "aws_iam_policy_document" "assume_role_policy_transcribe" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transcribe.amazonaws.com"]
    }
  }
}


# Custom policy
data "aws_iam_policy_document" "transcribe_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources = ["arn:aws:s3:::*"]
  }
  
  statement {
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:ViaService"

      values = ["s3.*.amazonaws.com"]
    }
  }

  statement {
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.data-science.arn}/*",
      aws_s3_bucket.data-science.arn
    ]
  }

  depends_on = [aws_s3_bucket.data-science]
}

resource "aws_iam_policy" "transcribe_policy" {
  name = "${var.project_name}-${var.env}-transcribe-policy"

  policy = data.aws_iam_policy_document.transcribe_policy.json
}

# Role
resource "aws_iam_role" "transcribe_role" {
  name               = "${var.project_name}-${var.env}-transcribe-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_transcribe.json
}

# Role attachments
resource "aws_iam_role_policy_attachment" "transcribe_role_custom_policy" {
  role       = aws_iam_role.transcribe_role.name
  policy_arn = aws_iam_policy.transcribe_policy.arn
}

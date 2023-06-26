resource "aws_security_group" "mks_sg" {
  name   = "mks-access-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    self        = true
  }

  // TODO: Remove once public access is not needed
  ingress {
    cidr_blocks = ["82.36.42.175/32"]
    description = "tamas@fyld.ai - HOME"
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["213.107.85.226/32"]
    description = "tamas@fyld.ai - Mobile data"
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kms_key" "kms" {
  description = "KMS for Kafka"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.project_name}-${var.env}-snowflake-cluster-logs-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "snowflake_log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_policy.default]
}

data "aws_iam_policy_document" "s3_policy_bucket" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "arn:aws:s3:::${var.project_name}-${var.env}-snowflake-cluster-logs-bucket",
      "arn:aws:s3:::${var.project_name}-${var.env}-snowflake-cluster-logs-bucket/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = data.aws_iam_policy_document.s3_policy_bucket.json
}

resource "aws_msk_configuration" "snowflake_cluster_config" {
  kafka_versions = ["2.8.1"]
  name           = "${var.project_name}-${var.env}-msk-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable=true
default.replication.factor=2
min.insync.replicas=1
num.io.threads=8
num.network.threads=5
num.partitions=1
num.replica.fetchers=2
replica.lag.time.max.ms=30000
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
socket.send.buffer.bytes=102400
unclean.leader.election.enable=true
zookeeper.session.timeout.ms=18000
PROPERTIES
}

resource "aws_msk_cluster" "snowflake_cluster" {
  cluster_name           = "${var.project_name}-${var.env}-snowflake-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = var.size
    ebs_volume_size = var.volume_size
    client_subnets = [
      var.subnet_ids[0],
      var.subnet_ids[1],
    ]
    security_groups = [aws_security_group.mks_sg.id]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn

    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.snowflake_cluster_config.arn
    revision = aws_msk_configuration.snowflake_cluster_config.latest_revision 

  }

  logging_info {
    broker_logs {
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.log_bucket.id
        prefix  = "logs/msk-"
      }
    }
  }
}
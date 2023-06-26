  # /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*arm64*"]
  }
}

resource "aws_instance" "snowflake-transfer" {
  ami                         = data.aws_ami.amazon_ami.image_id
  instance_type               = "t4g.small"
  key_name                    = "sitestream"
  vpc_security_group_ids      = [aws_security_group.mks_sg.id, var.database_sg]
  subnet_id                   = var.host_subnet_id
  associate_public_ip_address = true

  user_data                   = templatefile("${path.module}/install.sh", {
    private_key         = var.SNOWFLAKE_SYNC_PRIVATE_KEY,
    env                 = replace(var.env, "-", "_"),
    snowflake_password  = var.SNOWFLAKE_SYNC_PASSWORD,
    snowflake_schema    = "${var.project_name}_${replace(var.env, "-", "_")}"
    kafka_endpoints     = aws_msk_cluster.snowflake_cluster.bootstrap_brokers
    kafka_endpoint_1    = split(",", aws_msk_cluster.snowflake_cluster.bootstrap_brokers)[0]
    kafka_endpoint_2    = split(",", aws_msk_cluster.snowflake_cluster.bootstrap_brokers)[1]
    db_username         = var.db_username
    db_password         = var.db_password
    db_name             = var.project_name
    db_host             = var.db_host
  })

  metadata_options {
    http_tokens               = "required"
    http_endpoint             = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-snowflake-transfer"
    Environment = var.env
    Project     = var.project_name
  }
}

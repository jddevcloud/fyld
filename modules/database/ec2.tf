  # /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-arm64-gp2
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*arm64*"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_ami.image_id
  instance_type               = "t4g.nano"
  key_name                    = "sitestream"
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = var.bastion_subnet
  associate_public_ip_address = true

  user_data                   = templatefile("${path.module}/install.sh", {})

  metadata_options {
    http_tokens               = "required"
    http_endpoint             = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-bastion"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_key_pair" "app" {
  key_name   = var.project_name
  public_key = file(var.key_file)
}

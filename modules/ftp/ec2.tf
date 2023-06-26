# /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*arm64*"]
  }
}

resource "aws_instance" "ftp" {
  ami                         = data.aws_ami.amazon_ami.image_id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.ftp_key.key_name
  vpc_security_group_ids      = [aws_security_group.ftp.id]
  subnet_id                   = var.ftp_subnet
  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-ftp"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_eip" "ftp" {
  instance = aws_instance.ftp.id
  vpc      = true
}

resource "aws_key_pair" "ftp_key" {
  key_name   = "${var.project_name}-ftp"
  public_key = file(var.key_file)
}

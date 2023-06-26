# /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2
data "aws_ami" "amazon_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "pgbouncer" {
  ami                         = data.aws_ami.amazon_ami.image_id
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.pgbouncer_key.key_name
  vpc_security_group_ids      = [aws_security_group.pgbouncer.id, var.database_security_group]
  subnet_id                   = var.pgbouncer_subnet
  associate_public_ip_address = true

  user_data                   = templatefile("${path.module}/install.sh", {
    md5_password = "md5${md5("${var.bouncer_password}sitestream")}",
    rds_password = var.db_password,
    rds_host = var.db_host
  })

  metadata_options {
    http_tokens               = "required"
    http_endpoint             = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-pgbouncer"
    Environment = var.env
    Project     = var.project_name
  }

  # provisioner "file" {
  #   source      = "install.sh"
  #   destination = "/tmp/install.sh"
  # }
  
  # provisioner "file" {
  #   content     = templatefile("${path.module}/pgbouncer.ini", {  })
  #   destination = "/etc/pgbouncer/pgbouncer.ini"
  # }
  
  # provisioner "file" {
  #   content     = templatefile("${path.module}/userlist.txt", { md5_password = "md5${md5("${var.bouncer_password}sitestream")}" })
  #   destination = "/etc/pgbouncer/userlist.txt"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/install.sh",
  #     "/tmp/install.sh",
  #   ]
  # }
}

resource "aws_eip" "pgbouncer" {
  instance = aws_instance.pgbouncer.id
  vpc      = true
}

resource "aws_key_pair" "pgbouncer_key" {
  key_name   = "${var.project_name}-pgbouncer"
  public_key = file(var.key_file)
}

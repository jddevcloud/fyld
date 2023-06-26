resource "aws_security_group" "ftp" {
  name        = "ftp-access-${var.env}"
  description = "An ingress for the FTP Server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["82.36.42.175/32"]
    description = "tamas@fyld.ai - HOME"
  }

  ingress {
    from_port   = 1024
    to_port     = 1048
    protocol    = "tcp"
    cidr_blocks = ["82.36.42.175/32"]
    description = "tamas@fyld.ai - HOME"
  }

  ingress {
    cidr_blocks = ["82.36.42.175/32"]
    description = "tamas@fyld.ai - HOME"
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

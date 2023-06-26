resource "aws_security_group" "rds-access" {
  name        = "rds-access-${var.env}"
  description = "An ingress for all EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
      aws_security_group.elb-access.id,
      aws_security_group.bastion.id
    ]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-access" {
  name        = "elb-access-${var.env}"
  description = "An ingress for the Load Balancer"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "lambda_security_group" {
  value = aws_security_group.elb-access.id
}

resource "aws_security_group" "bastion" {
  name        = "bastion-access-${var.env}"
  description = "An ingress for the Bastion"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = ["82.36.42.175/32"]
    description = "tamas@fyld.ai - HOME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["213.86.26.4/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Tamas TOG Kings Cross"
  }
  
  ingress {
    cidr_blocks = ["80.169.18.4/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Tamas TOG Marylebone"
  }

  ingress {
    cidr_blocks = ["213.55.241.9/32"]
    description = "daniel@fyld.ai"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["44.216.161.18/32"]
    description = "jperozo@aclti.com"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["80.193.53.51/32"]
    description = "aleks@fyld.ai - LONDON"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["89.64.116.117/32"]
    description = "aleks@fyld.ai - Poland"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["5.71.224.227/32"]
    description = "emma@fyld.ai"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["86.9.129.134/32"]
    description = "monch@fyld.ai - HOME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["86.7.32.82/32"]
    description = "seamus@fyld.ai - HOME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["94.76.193.62/32"]
    description = "FYLD VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["154.14.2.114/32"]
    description = "tamas@fyld.ai - SGN Portsmouth"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["18.168.224.40/29", "35.246.19.240/29"]
    description = "Fivetran access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["37.156.74.198/32", "188.214.10.194/32", "37.156.74.193/32", "86.6.73.101/32"]
    description = "ylenio@fyld.ai - HOME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["81.108.17.157/32"]
    description = "shane@fyld.ai - HOME"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["185.169.255.157/32"]
    description = "shane@fyld.ai - Out of office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lambda-backup" {
  name        = "lambda-backup-access-${var.env}"
  description = "SG for the backup lambda function"
  vpc_id      = var.vpc_id

  ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lambda-database" {
  name        = "lambda-database-access-${var.env}"
  description = "SG for lambda functions requiring access to the DB"
  vpc_id      = var.vpc_id

  ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lambda-clamav" {
  name        = "lambda-clamav-access-${var.env}"
  description = "SG for the ClamAV lambda function"
  vpc_id      = var.vpc_id

  ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

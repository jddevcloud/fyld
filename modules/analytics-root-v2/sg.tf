resource "aws_security_group" "db-access" {
  name        = "analytics-db-access-${var.env}"
  description = "An ingress for the analytics db"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["52.25.130.38/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Segment access"
  }

  ingress {
    cidr_blocks = ["34.246.74.86/32", "52.215.158.213/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Tableau access"
  }

  ingress {
    cidr_blocks = ["89.35.199.31/32", "188.214.10.194/32", "37.156.74.193/32", "86.6.73.101/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Ylenio access"
  }

  ingress {
    cidr_blocks = ["82.36.42.175/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Tamas access"
  }
  
  ingress {
    cidr_blocks = ["213.86.26.4/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Tamas TOG Kings Cross"
  }

  ingress {
    cidr_blocks = ["109.128.9.152/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Daniel"
  }

  ingress {
    cidr_blocks = ["80.193.53.51/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Aleks London"
  }
  
  ingress {
    cidr_blocks = ["89.64.116.117/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "Aleks Poland"
  }

  ingress {
    cidr_blocks = ["5.71.224.227/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "emma@fyld.ai"
  }

  ingress {
    cidr_blocks = ["86.9.129.134/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "monch@fyld.ai - HOME"
  }

  ingress {
    cidr_blocks = ["86.7.32.82/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "seamus@fyld.ai - HOME"
  }

  ingress {
    cidr_blocks = ["94.76.193.62/32"]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    description = "FYLD VPN"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

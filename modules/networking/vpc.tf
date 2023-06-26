resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name        = "${var.project_name}-${var.env}"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-${var.env} Default Security Group"
  }
}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name        = "${var.project_name}-${var.env}-nat"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.env}"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name        = "${var.project_name}-${var.env}"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.env}-private"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.env}-public"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_route_table" "protected" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-${var.env}-protected"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "aws_route" "protected-to-nat" {
  route_table_id         = aws_route_table.protected.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.id
}

resource "aws_route" "public-to-igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "protected" {
  count          = length(var.protected_subnets)
  subnet_id      = aws_subnet.protected[count.index].id
  route_table_id = aws_route_table.protected.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.public.id, aws_route_table.private.id, aws_route_table.protected.id]

  tags = {
    Name        = "${var.project_name}-${var.env}-S3-Gateway"
    Environment = var.env
    Project     = var.project_name
  }
}
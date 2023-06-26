# Private subnets: these subnets have no internet access.
# Should be used for resources that require no access to the public internet
# such as databases, elasticsearch, elasticache, etc.

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(values(var.private_subnets), count.index)
  availability_zone = element(keys(var.private_subnets), count.index)

  tags = {
    Name        = "${var.project_name}-${var.env}-private-${element(keys(var.private_subnets), count.index)}"
    Environment = var.env
    Project     = var.project_name
  }
}


# Protected subnets: these subnets have internet access, but cannont be accessed from the internet.
# Should be used for resources that require access to the public internet
# such as lambdas, app servers, etc.

resource "aws_subnet" "protected" {
  count             = length(var.protected_subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(values(var.protected_subnets), count.index)
  availability_zone = element(keys(var.protected_subnets), count.index)

  tags = {
    Name        = "${var.project_name}-${var.env}-protected-${element(keys(var.protected_subnets), count.index)}"
    Environment = var.env
    Project     = var.project_name
  }
}

# Public subnets: these subnets have internet access and are accessible via the internet.
# Should be used for NAT Gateways and bastion hosts, etc. Instances launched in this subnet will get a public IP.

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(values(var.public_subnets), count.index)
  availability_zone       = element(keys(var.public_subnets), count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.env}-public-${element(keys(var.public_subnets), count.index)}"
    Environment = var.env
    Project     = var.project_name
  }
}

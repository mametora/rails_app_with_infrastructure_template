resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr[terraform.workspace]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

# public
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_a_cidr[terraform.workspace]
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-public-a"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_c_cidr[terraform.workspace]
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-public-c"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_subnet" "public_d" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnet_d_cidr[terraform.workspace]
  availability_zone       = "${var.region}d"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-public-d"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-public"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_d" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public.id
}

# private
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.private_subnet_a_cidr[terraform.workspace]
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private-a"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.private_subnet_c_cidr[terraform.workspace]
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private-c"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_subnet" "private_d" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.private_subnet_d_cidr[terraform.workspace]
  availability_zone       = "${var.region}d"
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private-d"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_eip" "nat_gateway_private_a" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-nat_gateway_private_a"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_eip" "nat_gateway_private_c" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-nat_gateway_private_c"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_eip" "nat_gateway_private_d" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-nat_gateway_private_d"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_nat_gateway" "private_a" {
  allocation_id = aws_eip.nat_gateway_private_a.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.default]
  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_a"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_nat_gateway" "private_c" {
  allocation_id = aws_eip.nat_gateway_private_c.id
  subnet_id     = aws_subnet.public_c.id
  depends_on    = [aws_internet_gateway.default]
  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_c"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_nat_gateway" "private_d" {
  allocation_id = aws_eip.nat_gateway_private_d.id
  subnet_id     = aws_subnet.public_d.id
  depends_on    = [aws_internet_gateway.default]
  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_d"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_a"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_c"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route_table" "private_d" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-private_d"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_route" "private_a" {
  route_table_id         = aws_route_table.private_a.id
  nat_gateway_id         = aws_nat_gateway.private_a.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1c" {
  route_table_id         = aws_route_table.private_c.id
  nat_gateway_id         = aws_nat_gateway.private_c.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private_1d" {
  route_table_id         = aws_route_table.private_d.id
  nat_gateway_id         = aws_nat_gateway.private_d.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}

resource "aws_route_table_association" "private_d" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private_d.id
}

resource "aws_vpc_endpoint" "ecr_api" {
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.default.id
  subnet_ids          = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id
  ]
  security_group_ids  = [module.vpc_endpoint_sg.this_security_group_id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-ecr-api"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.default.id
  subnet_ids        = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id
  ]

  security_group_ids  = [module.vpc_endpoint_sg.this_security_group_id]
  private_dns_enabled = true

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-ecr-dkr"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.default.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_c.id,
    aws_route_table.private_d.id,
  ]

  tags = {
    Name    = "${var.app_name}-${terraform.workspace}-s3"
    Env     = terraform.workspace
    Product = var.app_name
  }
}

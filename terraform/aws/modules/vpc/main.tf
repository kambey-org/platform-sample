resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.name
  }
}
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "ep" {
  vpc_id            = aws_vpc.main.id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = values(aws_route_table.private-rt)[*].id

  tags = {
    Name = "${var.name}-s3-endpoint"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.azs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_cidr
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.name}-subnet-public-${each.key}"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_route_table_association" "public" {
  for_each       = var.azs
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_subnets" {
  for_each          = var.azs
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.private_cidr
  availability_zone = each.key
  tags = {
    Name                              = "${var.name}-subnet-private-${each.key}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_eip" "nat_ip" {
  for_each = var.azs
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  for_each      = var.azs
  depends_on    = [aws_internet_gateway.main]
  allocation_id = aws_eip.nat_ip[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  tags = {
    Name = "${var.name}-${each.key}-nat-gw"
  }
}

resource "aws_route_table" "private-rt" {
  for_each = var.azs
  vpc_id   = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[each.key].id
  }
  tags = {
    Name = "${var.name}-${each.key}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.azs
  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private-rt[each.key].id
}
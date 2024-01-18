resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    name = "${var.prefix}-vpc"
  }
}
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  for_each                = var.public_subnets
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true # To ensure the instance gets a public IP

  tags = {
    Name = "${each.value.name}-public-subnet"
  }
}
resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.private_subnets
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  # map_public_ip_on_launch = true # To ensure the instance gets a public IP

  tags = {
    Name = "${each.value.name}-private-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-rt"
  }
}
resource "aws_route_table_association" "rta" {
  for_each  = var.public_subnets
  subnet_id = aws_subnet.public_subnets[each.key].id
  #subnet_id      = [module.subnets.subnet_ids["public_subnets"]]
  route_table_id = aws_route_table.rt.id
}
resource "aws_nat_gateway" "ngw" {
  for_each      = var.public_subnets
  subnet_id     = aws_subnet.public_subnets[each.key].id
  allocation_id = aws_eip.nat[each.key].id
}
resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"
}
resource "aws_route_table" "rt-nat" {
  vpc_id   = aws_vpc.vpc.id
  for_each = aws_nat_gateway.ngw
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[each.key].id
  }
  tags = {
    Name = "${var.prefix}-private-rt"
  }
}
resource "aws_route_table_association" "rt-nat" {
  for_each  = var.nat-rta
  subnet_id = aws_subnet.private_subnets[each.value.subnet_id].id
  #subnet_id      = [module.subnets.subnet_ids["public_subnets"]]
  route_table_id = aws_route_table.rt-nat[each.value.route_table_id].id
}

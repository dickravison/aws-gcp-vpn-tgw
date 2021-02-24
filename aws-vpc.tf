resource "aws_vpc" "vpc" {
  cidr_block           = var.aws_cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnets" {
  vpc_id     = aws_vpc.vpc.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block = "10.1.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_default_route_table" "def-rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

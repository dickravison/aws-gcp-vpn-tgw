resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit GW"
  auto_accept_shared_attachments = "enable"
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.gcp_cidr_range
    gateway_id = aws_ec2_transit_gateway.tgw.id
  }

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rt-association" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.rt.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment" {
  subnet_ids         = aws_subnet.subnets.*.id
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc.id
}

# route-tables.tf
resource "aws_route_table" "private-routing-table" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-nat-gateway.id
  }
}

resource "aws_route_table" "public-routing-table" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-central-1a.id
  route_table_id = aws_route_table.private-routing-table.id
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-central-1b.id
  route_table_id = aws_route_table.public-routing-table.id
}

resource "aws_route_table_association" "private-association2" {
  subnet_id      = aws_subnet.private-central-1b.id
  route_table_id = aws_route_table.private-routing-table.id
}

resource "aws_route_table_association" "public-association2" {
  subnet_id      = aws_subnet.public-central-1a.id
  route_table_id = aws_route_table.public-routing-table.id
}

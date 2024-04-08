# NAT.tf
resource "aws_eip" "nat-ip" {
  vpc      = true
}
resource "aws_nat_gateway" "my-nat-gateway" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = aws_subnet.public-central-1b.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

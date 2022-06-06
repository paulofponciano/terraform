# Nat Gateway for private subnets
resource "aws_eip" "main-ngw-1a" {
  vpc = true
  tags = {
    Name = "main-ngw-1a"
  }
}

resource "aws_eip" "main-ngw-1b" {
  vpc = true
  tags = {
    Name = "main-ngw-1b"
  }
}

resource "aws_nat_gateway" "main-ngw-1a" {
  allocation_id = aws_eip.main-ngw-1a.id
  subnet_id     = aws_subnet.main-subnet-public-1a.id
  depends_on    = [aws_internet_gateway.main-igw]
  tags = {
    Name = "main-ngw-1a"
  }
}

resource "aws_nat_gateway" "main-ngw-1b" {
  allocation_id = aws_eip.main-ngw-1b.id
  subnet_id     = aws_subnet.main-subnet-public-1b.id
  depends_on    = [aws_internet_gateway.main-igw]
  tags = {
    Name = "main-ngw-1b"
  }
}

# Route table and route to ngw
resource "aws_route_table" "main-rt-private-1a" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-ngw-1a.id
  }

  tags = {
    Name = "main-rt-private-1a"
  }
}

resource "aws_route_table" "main-rt-private-1b" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-ngw-1b.id
  }

  tags = {
    Name = "main-rt-private-1b"
  }
}

# Route associations private rt
resource "aws_route_table_association" "main-subnet-private-1a" {
  subnet_id      = aws_subnet.main-subnet-private-1a.id
  route_table_id = aws_route_table.main-rt-private-1a.id
}

resource "aws_route_table_association" "main-subnet-private-1b" {
  subnet_id      = aws_subnet.main-subnet-private-1b.id
  route_table_id = aws_route_table.main-rt-private-1b.id
}
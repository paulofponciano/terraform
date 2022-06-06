# New VPC 'main-vpc'
resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main-vpc"
  }
}

# 4 subnets 2 AZ's
resource "aws_subnet" "main-subnet-public-1a" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "main-subnet-public-1a"
  }
}

resource "aws_subnet" "main-subnet-public-1b" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "main-subnet-public-1b"
  }
}

resource "aws_subnet" "main-subnet-private-1a" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "main-subnet-private-1a"
  }
}

resource "aws_subnet" "main-subnet-private-1b" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "main-subnet-private-1b"
  }
}

# Internet GW
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Route tables
resource "aws_route_table" "main-rt-public" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "main-rt-public"
  }
}

# Route associations public rt
resource "aws_route_table_association" "main-public-1a" {
  subnet_id      = aws_subnet.main-subnet-public-1a.id
  route_table_id = aws_route_table.main-rt-public.id
}

resource "aws_route_table_association" "main-public-1b" {
  subnet_id      = aws_subnet.main-subnet-public-1b.id
  route_table_id = aws_route_table.main-rt-public.id
}
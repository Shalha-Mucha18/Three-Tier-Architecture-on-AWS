# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "custom-vpc"
  }
}

# Create an Internet Gateway (vpc_id below attaches it to the VPC directly)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "custom-igw"
  }
}

# Create a public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet1_cidr_block
  availability_zone       = var.public_subnet1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

# Create a public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2_cidr_block
  availability_zone       = var.public_subnet2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create route table for the public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Associate the public route table with public subnet 1
resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate the public route table with public subnet 2
resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Create private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet1_cidr_block
  availability_zone       = var.private_subnet1_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

# Create private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet2_cidr_block
  availability_zone       = var.private_subnet2_az
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}

# Create an EIP for each NAT Gateway
resource "aws_eip" "ngw_eip1" {
  domain = "vpc"
  tags = {
    Name = "ngw-eip"
  }
}

resource "aws_eip" "ngw_eip2" {
  domain = "vpc"
  tags = {
    Name = "EIP2"
  }
}

# Create a NAT Gateway in public subnet 1
resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.ngw_eip1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "ngw-1"
  }
}

# Create a NAT Gateway in public subnet 2
resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.ngw_eip2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "ngw-2"
  }
}

# Create the route table for private subnet 1
resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw1.id
  }
  tags = {
    Name = "private-rt-1"
  }
}

# Associate the route table with private subnet 1
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

# Create the route table for private subnet 2
resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw2.id
  }
  tags = {
    Name = "private-rt-2"
  }
}

# Associate the route table with private subnet 2
resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

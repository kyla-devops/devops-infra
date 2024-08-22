resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevOps-VPC"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "devops-private-subnet" {
  count = 2
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = var.private-cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "DevOps-Private-Subnet-${count.index}"
  }
}

resource "aws_subnet" "devops-public-subnet" {
  count = 2
  vpc_id = aws_vpc.devops-vpc.id
  cidr_block = var.public-cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "DevOps-Public-Subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "devops-internet-gateway" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = {
    Name = "DevOps-Internet-Gateway"
  }
}

resource "aws_security_group" "devops-security-group" {
  vpc_id = aws_vpc.devops-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.16.69.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DevOps-Security-Group"
  }
}

resource "aws_route_table" "devops-public-route-table" {
  vpc_id = aws_vpc.devops-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-internet-gateway.id
  }
  tags = {
    Name = "DevOps-Public-Route-Table"
  }
}

resource "aws_route_table_association" "devops-public-route-table-association" {
  count = 2
  subnet_id = aws_subnet.devops-public-subnet[count.index].id
  route_table_id = aws_route_table.devops-public-route-table.id
}

resource "aws_route_table" "devops-private-route-table" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = {
    Name = "DevOps-Private-Route-Table"
  }
}

resource "aws_route_table_association" "devops-private-route-table-association" {
  count = 2
  subnet_id = aws_subnet.devops-private-subnet[count.index].id
  route_table_id = aws_route_table.devops-private-route-table.id
}
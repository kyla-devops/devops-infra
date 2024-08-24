provider "aws" {
    region = "ap-south-1"
    profile = "devops-user-profile"
}

data "aws_subnets" "devops-public-subnets" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Public-Subnet*"]
  }
}

data "aws_subnets" "devops-private-subnets" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Private-Subnet*"]
  }
}

data "aws_vpc" "devops-vpc" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-VPC"]
  }
}

resource "aws_eip" "devops-eip" {
  domain = "vpc"
  tags = {
    Name = "DevOps-EIP"
  }
}

resource "aws_nat_gateway" "devops-nat-gateway" {
  allocation_id = aws_eip.devops-eip.id
  subnet_id = data.aws_subnets.devops-public-subnets.ids[1]
  tags = {
    Name = "DevOps-NAT-Gateway"
  }
}

resource "aws_route_table" "devops-private-route-table" {
  vpc_id = data.aws_vpc.devops-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.devops-nat-gateway.id
  }
  tags = {
    Name = "DevOps-Private-Route-Table"
  }
}

resource "aws_route_table_association" "devops-private-route-table-association" {
  count = 2
  subnet_id = data.aws_subnets.devops-private-subnets.ids[count.index]
  route_table_id = aws_route_table.devops-private-route-table.id
}
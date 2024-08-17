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

resource "aws_vpc" "devops-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DevOps-VPC"
  }
}

data "aws_availability_zones" "available" {}

#Creating 2 private-subnets to be used for 2 private EC2 instances
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

#Creating 1 public-subnet to be used for Bastion public EC2 instance
resource "aws_subnet" "devops-public-subnet" {
  count = 1
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

#Public-security-group to be attached with bastion. Here, it is allowing cidrs of 2 users to be allowed to connect via ssh, 1 ingress rule to allow http traffic from internet (to make application accessible) and 3rd ingress block to allow traffic from private ec2s.
resource "aws_security_group" "devops-public-security-group" {
  vpc_id = aws_vpc.devops-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.16.69.0/24","121.241.130.0/24","122.171.19.0/24"] #kyla2 & srinivas1 ip-range
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.2.123/32","10.0.1.79/32"] #private ec2-0 & ec2-1 private ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DevOps-Public-Security-Group"
  }
}

#Private-security-group to be attached with private-ec2s. The ingress block here is allowing traffic from the bastion public and private IPs.
resource "aws_security_group" "devops-private-security-group" {
  vpc_id = aws_vpc.devops-vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.3.233/32"] #bastion private ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "DevOps-Private-Security-Group"
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
  count = 1
  subnet_id = aws_subnet.devops-public-subnet[count.index].id
  route_table_id = aws_route_table.devops-public-route-table.id
}

#Below blocks moved to NAT gateway because we need below route-table for nat-gateway only. Private EC2 do not allow inbound/outbound traffic anyways.
# resource "aws_route_table" "devops-private-route-table" {
#   vpc_id = aws_vpc.devops-vpc.id
#   tags = {
#     Name = "DevOps-Private-Route-Table"
#   }
# }

# resource "aws_route_table_association" "devops-private-route-table-association" {
#   count = 2
#   subnet_id = aws_subnet.devops-private-subnet[count.index].id
#   route_table_id = aws_route_table.devops-private-route-table.id
# }
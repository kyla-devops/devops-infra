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

data "aws_security_group" "devops-security-group" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Security-Group"]
  }
}

resource "aws_instance" "devops-public-ec2" {
  count = length(data.aws_subnets.devops-public-subnets.ids)
  ami = var.ami
  instance_type = var.instance-type
  subnet_id = data.aws_subnets.devops-public-subnets.ids[count.index]
  security_groups = [data.aws_security_group.devops-security-group.id]
  associate_public_ip_address = true
  tags = {
    Name = "DevOps-Public-EC2-${count.index}"
  }
}

# resource "aws_instance" "devops-private-ec2" {
#   count = length(data.aws_subnets.devops-private-subnets.ids)
#   ami = var.ami
#   instance_type = var.instance-type
#   subnet_id = data.aws_subnets.devops-private-subnets.ids[count.index]
#   security_groups = [data.aws_security_group.devops-security-group.id]
#   associate_public_ip_address = false
#   tags = {
#     Name = "DevOps-Private-EC2-${count.index}"
#   }
# }
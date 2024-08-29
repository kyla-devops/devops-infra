#This block is commented because we will not create public ec2 instances now.
# data "aws_subnets" "devops-public-subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["DevOps-Public-Subnet*"]
#   }
# }

#Public EC2 instance block is commented because now we will use private-ec2 with bastion working as jumphost, proxy and reverse-proxy.
# resource "aws_instance" "devops-public-ec2" {
#   count = length(data.aws_subnets.devops-public-subnets.ids)
#   ami = var.ami
#   instance_type = var.instance-type
#   subnet_id = data.aws_subnets.devops-public-subnets.ids[count.index]
#   security_groups = [data.aws_security_group.devops-security-group.id]
#   key_name = var.key-name
#   associate_public_ip_address = true
#   tags = {
#     Name = "DevOps-Public-EC2-${count.index}"
#   }
#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update -y && apt-get upgrade -y
#               apt-get install -y apache2
#               systemctl start apache2
#               EOF
# }

data "aws_subnets" "devops-private-subnets" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Private-Subnet*"]
  }
}

data "aws_security_group" "devops-private-security-group" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Private-Security-Group"]
  }
}

#Attaching the private-security-group which will allow bastion IPs to connect.
resource "aws_instance" "devops-private-ec2" {
  count = length(data.aws_subnets.devops-private-subnets.ids)
  ami = var.ami
  instance_type = var.instance-type
  subnet_id = data.aws_subnets.devops-private-subnets.ids[count.index]
  security_groups = [data.aws_security_group.devops-private-security-group.id]
  key_name = var.key-name
  associate_public_ip_address = false
  # user_data = file("../../templates/ec2-instance/apache.sh")
  tags = {
    Name = "DevOps-Private-EC2-${count.index}"
  }
}
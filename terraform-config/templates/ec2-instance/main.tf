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
  key_name = var.key-name
  associate_public_ip_address = true
  tags = {
    Name = "DevOps-Public-EC2-${count.index}"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y && apt-get upgrade -y
              apt-get install -y apache2
              systemctl start apache2
              EOF
}

resource "aws_instance" "devops-private-ec2" {
  count = length(data.aws_subnets.devops-private-subnets.ids)
  ami = var.ami
  instance_type = var.instance-type
  subnet_id = data.aws_subnets.devops-private-subnets.ids[count.index]
  security_groups = [data.aws_security_group.devops-security-group.id]
  key_name = var.key-name
  associate_public_ip_address = false
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y && apt-get upgrade -y
              apt-get install -y apache2
              systemctl start apache2
              EOF
  tags = {
    Name = "DevOps-Private-EC2-${count.index}"
  }
}
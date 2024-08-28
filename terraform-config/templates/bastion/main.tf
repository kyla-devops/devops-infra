data "aws_subnet" "devops-public-subnet" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Public-Subnet-0"]
  }
}

data "aws_security_group" "devops-public-security-group" {
  filter {
    name   = "tag:Name"
    values = ["DevOps-Public-Security-Group"]
  }
}

resource "aws_instance" "devops-bastion" {
  ami = var.ami
  instance_type = var.instance-type
  subnet_id = data.aws_subnet.devops-public-subnet.id
  security_groups = [data.aws_security_group.devops-public-security-group.id]
  key_name = var.key-name
  associate_public_ip_address = true
  # user_data = file("../../templates/bastion/squid.sh")
  tags = {
    Name = "DevOps-Bastion-EC2"
  }
}

output "devops-bastion-public-ip" {
  value = aws_instance.devops-bastion.public_ip
  description = "Public IP of the Bastion Host Created"
}
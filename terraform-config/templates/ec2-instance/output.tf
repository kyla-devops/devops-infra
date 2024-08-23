output "devops-public-ec2-ips" {
  value = aws_instance.devops-public-ec2[*].public_ip
}
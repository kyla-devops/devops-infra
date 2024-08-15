resource "aws_instance" "k8scluster" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key
}
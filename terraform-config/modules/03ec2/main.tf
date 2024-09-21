module "vpc-creation" {
    source = "../../templates/ec2-instance"
    instance-type = "t3a.xlarge"
}
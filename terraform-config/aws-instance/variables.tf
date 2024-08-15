variable ami {
    type = string
    default = "ami-0ad21ae1d0696ad58"
    description = "EC2 instance in India region with Ubuntu"
}
variable user {
    type = list(string)
    default = ["devops-user","DevOps User for all implementation"]
}
variable ami {
    type = string
    default = "ami-0ad21ae1d0696ad58"
    description = "EC2 instance in India region with Ubuntu"
}
variable user {
    type = string
    default = "devops-user"
}
variable policy_name {
    type = list(string)
    default = ["DevOps-Policy","../user-creation/devops-policy.json"]
}
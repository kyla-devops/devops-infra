module "user-creation" {
    source = "../../templates/user-creation"
    ami = "ami-0ad21ae1d0696ad58"
    user = "devops-user"
}
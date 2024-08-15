resource "aws_iam_user" "devops-user" {
    name = var.user[0]
    tags = {
        Description = var.user[1]
    }
}
resource "aws_iam_policy" "devops-policy" {
    name = "DevOps-User"
    policy = file("devops-policy.json")
}

resource "aws_iam_user_policy_attachment" "devops-access" {
    user = aws_iam_user.devops-user.name
    policy_arn = aws_iam_policy.devops-policy.arn
}

# resource "aws_instance" "k8scluster" {
#     ami = var.ami
#     instance_type = "t2.micro"
#     key_name = var.key
# }
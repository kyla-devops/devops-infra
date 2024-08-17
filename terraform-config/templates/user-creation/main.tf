resource "aws_iam_user" "devops-user" {
    name = var.user
    tags = {
      Name = "${var.user}"
    }
}

resource "aws_iam_policy" "devops-policy" {
    name = var.policy_name[0]
    policy = file(var.policy_name[1])
    tags = {
      Name = "${var.policy_name[0]}"
    }
}

resource "aws_iam_user_policy_attachment" "devops-access" {
    user = aws_iam_user.devops-user.name
    policy_arn = aws_iam_policy.devops-policy.arn
}
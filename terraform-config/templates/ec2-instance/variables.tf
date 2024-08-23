variable key-name {
  type = string
  default = "devops-key-pair"
}

variable "ami" {
  type = string
  default = "ami-0522ab6e1ddcc7055"
}
variable "instance-type" {
  type = string
  default = "t2.micro"
}
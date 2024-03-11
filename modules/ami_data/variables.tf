locals {
  instance_type = "t2.micro"
}

variable "ami_name" {
  type    = list(string)
  default = ["amzn2-ami-kernel-5.10-hvm-*"]
  # default = ["ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-pro-server-*"]
}

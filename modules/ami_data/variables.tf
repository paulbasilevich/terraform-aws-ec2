variable "instance_type" {
  type = string
  description = "Type of the target EC2 instance"
  default = "t2.micro"
}

variable "ami_name" {
  type    = string
  default = "amzn2-ami-kernel-5.10-hvm-*"
  # default = "ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-pro-server-*"
}

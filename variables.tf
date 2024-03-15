locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

variable "ami_name" {
  type    = list(string)
  description = "Name pattern to find the sought AMI by"
  default = ["amzn2-ami-kernel-5.10-hvm-*"]
  # default = ["ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-pro-server-*"]
}

variable "cidr_scope" {
  type = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default = "my_host"
}

variable "install_nginx" {
  type        = bool
  description = "Install nginx on the target host and http to its public_ip"
  default     = false
}

variable "demo_nginx" {
  type        = bool
  description = "Open nginx home page at the target host's public_ip"
  default     = false
}

locals {
  default_ami_name   = ["amzn2-ami-kernel-5.10-hvm-*"]
  default_cidr_scope = "my_host"
}

variable "ami_name" {
  type        = map(list(string))
  description = "Name pattern to find the sought AMI by"
  default = {
    default = ["amzn2-ami-kernel-5.10-hvm-*"]
    amzn    = ["amzn2-ami-kernel-5.10-hvm-*"]
    ubuntu  = ["ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-pro-server-*"]
  }
}

variable "cidr_scope" {
  type        = map(string)
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default = {
    default = "my_host"
    amzn    = "my_cidr"
  }
}

variable "install_nginx" {
  type        = bool
  description = "Install nginx on the target host and http to its public_ip"
  default     = false
}

variable "demo_nginx" {
  type        = bool
  description = "Install nginx on the target host and http to its public_ip"
  default     = false
}


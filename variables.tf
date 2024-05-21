variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_host"
}

variable "extra_cidr" {
  type        = string
  description = "CIDR block to be added by hand"
  default     = "192.168.0.5/32"
}

variable "ami_name_pattern" {
  type = string
  #  default = "amzn2-ami-kernel-5.10-hvm-*"
  default = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-*"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "plaid"
}

variable "aws_profile" {
  type        = string
  description = "Declare the AWS profile to use for this deployment"
  default     = "default"
}

variable "aws_region" {
  type        = string
  description = "Declare the AWS region for this deployment"
  default     = "us-west-2"
}

variable "ec2_instance_type" {
  type        = string
  description = "Type of the target EC2 instance"
  default     = "t2.micro"
}

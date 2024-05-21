variable "ami_name_pattern" {
  type    = string
  default = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-*"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "plaid"
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_cidr"
}

variable "extra_cidr" {
  type        = string
  description = "CIDR block to be added by hand"
  default     = "10.0.0.0/16"
}

variable "plaid_root_directory" {
  type        = string
  description = "Local destination of <git clone https://github.com/plaid/quickstart.git>"
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


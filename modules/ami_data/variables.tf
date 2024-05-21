variable "instance_type" {
  type        = string
  description = "Type of the target EC2 instance"
  default     = "t2.micro"
}

variable "ami_name_pattern" {
  type = string
  # default = "amzn2-"
  # default = "RHEL-9.3.0_HVM-"
  default = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-"
}

variable "ami_patterns" {
  type        = list(string)
  description = "AMI name patterns with the default user name ec2-user"
  default     = ["amzn2-", "RHEL-"]
}


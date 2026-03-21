variable "ami_name_pattern" {
  type        = string
  description = "Wildcard name pattern for quering the AMI ID"
  default     = "ubuntu-pro-server/images/hvm-ssd-gp3"
}

variable "ami_patterns" {
  type        = list(string)
  description = "AMI name patterns with the default user name ec2-user"
  default     = ["amzn", "RHEL", "Amazon Linux 2023"]
}


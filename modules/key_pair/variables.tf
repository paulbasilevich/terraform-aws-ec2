variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "tf"
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




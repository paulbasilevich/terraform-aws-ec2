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

variable "scripts_home" {
  type        = string
  description = "Centralized location of the shell scripts"
  default     = "./scripts"
}

variable "aws_secret_name" {
  type        = string
  description = "Name of the AWS secret"
  default     = "Plaid_Credentials"
}

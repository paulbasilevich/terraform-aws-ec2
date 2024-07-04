variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_host"
}

variable "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "extra_cidr" {
  type        = string
  description = "CIDR block to be added by hand"
  default     = ""
}

variable "aws_profile" {
  type        = string
  description = "Declare the AWS profile to use for this deployment"
  default     = "default"
}

variable "aws_secret_name" {
  type        = string
  description = "Name of the AWS secret"
  default     = "Plaid_Credentials"
}

variable "scripts_home" {
  type        = string
  description = "Centralized location of the shell scripts"
  default     = "../../scripts"
}


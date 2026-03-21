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

variable "common_name_root" {
  type        = string
  description = "Family name for all deployed resources"
  default     = "Sandbox"
}

variable "plaid_external" {
  type        = bool
  description = "Enforce external Plaid credentials"
  default     = false
}

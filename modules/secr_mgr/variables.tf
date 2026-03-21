variable "aws_profile" {
  type        = string
  description = "Declare the AWS profile to use for this deployment"
  default     = "default"
}

variable "client_var_name" {
  type        = string
  description = "The name of client id variable"
  default     = "PLAID_CLIENT_ID"
}

variable "secret_var_name" {
  type        = string
  description = "The name of client secret variable"
  default     = "PLAID_SECRET"
}

variable "aws_secret_name" {
  type        = string
  description = "Name of the AWS secret"
  default     = "Vault"
}

variable "scripts_home" {
  type        = string
  description = "Centralized location of the shell scripts"
  default     = "./scripts"
}

variable "plaid_external" {
  type        = bool
  description = "Enforce external Plaid credentials"
  default     = false
}

variable "common_name_root" {
  type        = string
  description = "Family name for all deployed resources"
  default     = "Sandbox"
}

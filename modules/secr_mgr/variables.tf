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

variable "tags_bootstrap" {
  description = "Blueprint for tags to be generated from and applied to all resources"
  type        = map(string)
  default = {
    Name = "Showcase"
  }
}

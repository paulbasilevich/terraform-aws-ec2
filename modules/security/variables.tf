variable "sg_ports" {
  type        = map(any)
  description = "Ingress ports defined in terraform.tfvars"
  default = {
    22 : "SSH",
    80 : "HTTP",
    443 : "HTTPS",
    8000 : "Plaid",
  }
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_host"
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


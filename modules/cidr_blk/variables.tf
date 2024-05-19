variable "env_status" {
  type        = number
  description = "Captured the status of the calling environment: 0 - good to go; >0 - fail."
  default     = 1
}

locals {
  env_status = tonumber(join(", ", split(" ", values(data.external.check_env.result)[0])))
}

locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
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

locals {
  cidr_blocks = split(" ", values(data.external.my_cidr.result)[0])
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


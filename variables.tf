locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

variable "install_nginx" {
  type        = bool
  description = "Install nginx on the target host and http to its public_ip"
  default     = false
}

variable "demo_nginx" {
  type        = bool
  description = "Open nginx home page at the target host's public_ip"
  default     = false
}

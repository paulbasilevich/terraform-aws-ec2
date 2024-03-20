# Do not delete "ssh_key_name" definition:
# otherwise the restoration of ~/.ssh settings upon resource destruction will not work!!!
# Modification of the definition is admissible, e.g.,:
#   ssh_key_name = "desired_name"

locals {
  ssh_key_name = "tf"
}

variable "lan_host_name" {
  description = "Name of a host in LAN context as defined in ~./ssh/config_home: e.g., <p> or <kisik>"
  type        = string
  default     = "p"
}

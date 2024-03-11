variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "tf"
}


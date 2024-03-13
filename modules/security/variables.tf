variable "sg_ports" {
  type        = map(any)
  description = "Ingress ports defined in terraform.tfvars"
  default = {
    22 : "SSH",
    80 : "HTTP",
    443 : "HTTPS",
  }
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_host"
}

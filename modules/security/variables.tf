variable "sg_ports" {
  type        = map(any)
  description = "Ingress ports defined in terraform.tfvars"
  default = {
    22 : "SSH",
    80 : "HTTP",
    443 : "HTTPS",
  }
}

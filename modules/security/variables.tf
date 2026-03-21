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
  default     = null
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
  default     = "./scripts"
}

variable "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_config" {
  description = "Subnet specs. Here reduced to the subnet role attributes, but can be expanded"
  type        = list(map(string))
  default = [
    {
      role = "public"
      type = "t2.micro"
    },
    {
      role = "private"
      type = "t2.micro"
    }
  ]
}

variable "common_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Name = "Plaid"
  }
}

variable "ec2_instance_count" {
  description = "If 1 - create only public subnet; 2 - add private subnet"
  type        = number
  default     = 1
}

variable "backend_port" {
  description = "Port the remote backend server listens on"
  type        = number
  default     = 8000
}

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

variable "tags_bootstrap" {
  description = "Blueprint for tags to be generated from and applied to all resources"
  type        = map(string)
  default = {
    Name = "Showcase"
  }
}

variable "deployment_subnet" {
  description = "Target subnet for provisioning EC2 instance: 'public' or 'private'"
  type        = string
  default     = "public"
}

variable "frontend_port" {
  description = "Port the frontend communicates with the backend server through"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Port the remote backend server listens on"
  type        = number
  default     = 8000
}

variable "time_zone" {
  type        = string
  description = "Time zone current time is evaluated in. Default - retrived from the system"
  default     = ""
}


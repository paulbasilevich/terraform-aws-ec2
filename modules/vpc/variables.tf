variable "aws_profile" {
  type        = string
  description = "Declare the AWS profile to use for this deployment"
  default     = "default"
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_host"
}

variable "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "extra_cidr" {
  type        = string
  description = "CIDR block to be added by hand"
  default     = null
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

variable "deployment_subnet" {
  description = "Target subnet for provisioning EC2 instance: 'public' or 'private'"
  type        = string
  default     = "public"
}

variable "tags_bootstrap" {
  description = "Blueprint for tags to be generated from and applied to all resources"
  type        = map(string)
  default = {
    Name = "Showcase"
  }
}

variable "scripts_home" {
  type        = string
  description = "Centralized location of the shell scripts"
  default     = "./scripts"
}

variable "time_zone" {
  type        = string
  description = "Time zone current time is evaluated in. Default - retrived from the system"
  default     = ""
}

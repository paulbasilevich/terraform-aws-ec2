variable "ami_name_pattern" {
  type        = string
  description = "Wildcard name pattern the target AMI ID is searched by"
  default     = "ubuntu-pro-server/images/hvm-ssd-gp3"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "pilot"
}

variable "lb_suffix" {
  type        = string
  description = "Suffix to ssh Host running the load balancer. Appends to the Host running the app."
  default     = "f"
}

variable "static_extra_key" {
  type        = string
  description = "Static extra ssh key for short typing"
  default     = "h"
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_cidr"
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

variable "plaid_external" {
  type        = bool
  description = "Enforce external Plaid credentials"
  default     = false
}

variable "web_browser" {
  type        = string
  description = "For example, 'Google Chrome' of 'Safari'"
  default     = "Google Chrome"
}

variable "tab_title" {
  type        = string
  description = "Title of the browser tab the target web app runs on"
  default     = "Plaid Quickstart"
}

variable "button_names" {
  type        = list(string)
  description = <<-EOT
Name of the start-off button on the welcome page.
Second button comes up in a pop-up box and hence is dummy for now.
EOT
  default = [
    "Launch Link",
    "Continue as guest"
  ]
}

variable "tags_bootstrap" {
  description = "Blueprint for tags to be generated from and applied to all resources"
  type        = map(string)
  default = {
    Name = "Showcase"
  }
}

variable "time_zone" {
  type        = string
  description = "Time zone current time is evaluated in. Default - retrived from the system"
  default     = ""
}

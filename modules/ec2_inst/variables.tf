variable "ami_name_pattern" {
  type        = string
  description = "Wildcard name pattern the target AMI ID is searched by"
  default     = "ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-"
  # default = "RHEL-9.3.0_HVM-"
  # default = "RHEL-"
  # default = "amzn2-"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the dynamically generated ssh key for connection to the EC2 instance"
  default     = "plaid"
}

variable "cidr_scope" {
  type        = string
  description = "Type of ingress CIDR block: 'my_host' - my_IP/32; 'my_cidr' - CIDR this host is on"
  default     = "my_cidr"
}

variable "extra_cidr" {
  type        = string
  description = "CIDR block to be added by hand"
  default     = "37.19.211.0/24"
}

variable "aws_profile" {
  type        = string
  description = "Declare the AWS profile to use for this deployment"
  default     = "default"
}

variable "ec2_instance_type" {
  type        = string
  description = "Type of the target EC2 instance"
  default     = "t2.micro"
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

variable "common_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Name = "Plaid"
  }
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

variable "backend_port" {
  description = "Port the remote backend server listens on"
  type        = number
  default     = 8000
}

variable "vpc_cidr" {
  description = "CIDR block allocated for the custom vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_config" {
  type = list(map(string))

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

variable "ec2_instance_count" {
  description = "If 1 - create only public subnet; 2 - add private subnet"
  type        = number
  default     = 1
}

variable "common_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default = {
    Name = "Plaid"
  }
}

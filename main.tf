module "ec2_inst" {
  source            = "./modules/ec2_inst"
  cidr_scope        = var.cidr_scope
  extra_cidr        = var.extra_cidr
  ami_name_pattern  = var.ami_name_pattern
  aws_profile       = var.aws_profile
  ec2_instance_type = var.ec2_instance_type
  aws_secret_name   = var.aws_secret_name
}

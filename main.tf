module "ec2_inst" {
  source            = "./modules/ec2_inst"
  ami_name_pattern  = var.ami_name_pattern
  ssh_key_name      = var.ssh_key_name
  cidr_scope        = var.cidr_scope
  extra_cidr        = var.extra_cidr
  aws_profile       = var.aws_profile
  ec2_instance_type = var.ec2_instance_type
  aws_secret_name   = var.aws_secret_name
  scripts_home      = var.scripts_home
  common_tags       = var.common_tags
  vpc_cidr          = var.vpc_cidr
  deployment_subnet = var.deployment_subnet
}

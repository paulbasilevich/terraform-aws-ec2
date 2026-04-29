module "ec2_inst" {
  source            = "./modules/ec2_inst"
  ami_name_pattern  = var.ami_name_pattern
  ssh_key_name      = var.ssh_key_name
  cidr_scope        = var.cidr_scope
  extra_cidr        = var.extra_cidr
  aws_profile       = var.aws_profile
  subnet_config     = var.subnet_config
  scripts_home      = local.scripts_home
  tags_bootstrap    = var.tags_bootstrap
  vpc_cidr          = var.vpc_cidr
  deployment_subnet = var.deployment_subnet
  plaid_external    = var.plaid_external
  time_zone = var.time_zone
}

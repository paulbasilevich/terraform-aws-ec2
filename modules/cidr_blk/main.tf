module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

module "secr_mgr" {
  source          = "../../modules/secr_mgr"
  aws_secret_name = var.aws_secret_name
  scripts         = var.scripts
}

data "external" "my_cidr" {
  program = ["bash", "${module.secr_mgr.scripts}/my_cidr.sh"]
  query = {
    cidr_scope = var.cidr_scope
    extra_cidr = var.extra_cidr
  }
}


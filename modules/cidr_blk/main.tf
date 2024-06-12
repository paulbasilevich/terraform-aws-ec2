module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

data "external" "my_cidr" {
  program = ["bash", "${var.scripts_home}/my_cidr.sh"]
  query = {
    cidr_scope = var.cidr_scope
    extra_cidr = var.extra_cidr
  }
}


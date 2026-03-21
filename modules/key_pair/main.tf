module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

module "secr_mgr" {
  source         = "../../modules/secr_mgr"
  scripts_home   = var.scripts_home
  plaid_external = var.plaid_external
}

data "external" "private_key" {
  program = ["bash", "${var.scripts_home}/private_key.sh"]
  query = {
    ssh_key_name   = var.ssh_key_name
    ssh_config_tag = var.ssh_key_name
    env_status     = module.secr_mgr.env_status
  }
}

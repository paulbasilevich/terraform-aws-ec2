module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

module "secr_mgr" {
  source          = "../../modules/secr_mgr"
  aws_secret_name = var.aws_secret_name
  scripts_home    = var.scripts_home
}

data "external" "private_key" {
  program = ["bash", "${var.scripts_home}/private_key.sh"]
  query = {
    ssh_key_name   = var.ssh_key_name
    ssh_config_tag = var.ssh_key_name
    env_status     = module.secr_mgr.env_status
  }
}

# Must match key_name and config_tag
# as key_name is the only relevant attribute retrievable from "self" -
# a must for provisioner-destroyer.
#

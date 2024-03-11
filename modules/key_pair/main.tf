data "external" "private_key" {
  program = ["bash", "${path.module}/private_key.sh"]
  query = {
    ssh_key_name   = var.ssh_key_name
    ssh_config_tag = var.ssh_key_name
  }
}

# Must match key_name and config_tag
# as key_name is the only relevant attribute retrievable from "self" -
# a must for provisioner-destroyer.
#

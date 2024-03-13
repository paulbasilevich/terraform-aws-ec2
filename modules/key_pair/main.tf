data "external" "public_key" {
  program = ["bash", "${path.module}/public_key.sh"]
  query = {
    ssh_key_name   = local.ssh_key_name
    ssh_config_tag = local.ssh_key_name
  }
}
# ^^^^^^^^^^ Must match key_name and config_tag
# as key_name is the only relevant attribute retrievable from "self" -
# a must for provisioner-destroyer.
#

resource "aws_key_pair" "tf" {
  key_name = local.ssh_key_name
  public_key = join(",", values(data.external.public_key.result))
}

resource "null_resource" "revert_ssh" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f ~/.ssh/$( grep ssh_key_name ${path.module}/variables.tf | cut -d'=' -f2 | tr -d '" ' )_rsa
      sed -E -i \
      -e "/^Host[[:space:]]+$( grep ssh_key_name ${path.module}/variables.tf | cut -d'=' -f2 | tr -d '" ' )$/,/^$/d" \
      ~/.ssh/config
      if [[ -f ~/.ssh/config_backup_tf ]]; then mv -f ~/.ssh/config_backup_tf ~/.ssh/config; fi
    EOT
  }
}
    

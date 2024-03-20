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
# In fact, "ssh_config_tag" is a legacy setting no longer used

# This resource leverages "ssh-keygen" function
# through "public_ip.sh" script interfaced via "external.public_key" data source
# defined above
resource "aws_key_pair" "tf" {
  key_name = local.ssh_key_name
  public_key = join(",", values(data.external.public_key.result))
}

# This resource generates a command that opens the target EC2 IP as a web site, e.g., nginx
# It is self-aware of the calling environment type:
# For Linux, it assumes to be running from a hosted VM with no browser,
#     and, as such, attempts to SSH to the VM's host expected to be set up in ~/.ssh/config
#     and identified by "Host" value matching "var.lan_host_name" showing below.
# For other OS, (tested on mac a.k.a. Darwin), simply leverages "open" command issued locally,
#     and disgerards the "var.lan_host_name" setting.
data "external" "sup" {
  program = ["bash", "${path.module}/ssh_up_from_vm.sh"]
  query = {
    host = var.lan_host_name
  }
}

# The purpose of this resource is to clean up ~/.ssh directory
# Updated to support "ssh tf" invocation an the instance creation time
resource "null_resource" "revert_ssh" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f ~/.ssh/$( grep -e "^[[:space:]]*ssh_key_name[[:space:]]*=" ${path.module}/variables.tf \
        | cut -d'=' -f2 | tr -d '" ' )_rsa
      sed -E -i \
      -e "/^Host[[:space:]]+$( grep -e "^[[:space:]]*ssh_key_name[[:space:]]*=" ${path.module}/variables.tf \
        | cut -d'=' -f2 | tr -d '" ' )$/,/^$/d" ~/.ssh/config
      if [[ -f ~/.ssh/config_backup_tf ]]; then mv -f ~/.ssh/config_backup_tf ~/.ssh/config; fi
    EOT
  }
}


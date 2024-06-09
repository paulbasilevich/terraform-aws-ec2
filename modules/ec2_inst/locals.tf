locals {
  time = format("%s PDT", formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "-7h")))
}

locals {
  plaid_root_directory = module.key_pair.ssh_key_name
}

locals {
  install = module.ami_data.yum_pattern ? "deploy_rhel.sh" : "deploy_ubuntu.sh"
}

locals {
  connect = {
    type        = "ssh"
    host        = "self.public_ip"
    user        = module.ami_data.user
    private_key = module.key_pair.private_key
  }
}

locals {
  scripts = module.key_pair.scripts
}

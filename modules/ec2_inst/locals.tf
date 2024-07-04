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
  instance_config = [
    {
      role = "public"
      snid = module.security.public_subnet_id
      prip = join("", [regex("((\\d{1,3}.){3})", module.security.public_subnet_cidr)[0], "10"])
    },
    {
      role = "private"
      snid = module.security.private_subnet_id
      prip = join("", [regex("((\\d{1,3}.){3})", module.security.private_subnet_cidr)[1], "10"])
    }
  ]
}

locals {
  ec2_instance_count = var.deployment_subnet == "public" ? 1 : 2
}

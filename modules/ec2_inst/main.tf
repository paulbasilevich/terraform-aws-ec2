module "security" {
  source          = "../../modules/security"
  cidr_scope      = var.cidr_scope
  extra_cidr      = var.extra_cidr
  aws_profile     = var.aws_profile
  aws_secret_name = var.aws_secret_name
  scripts_home    = var.scripts_home
}

module "ami_data" {
  source           = "../../modules/ami_data"
  ami_name_pattern = var.ami_name_pattern
  instance_type    = var.ec2_instance_type
}

module "key_pair" {
  source          = "../../modules/key_pair"
  ssh_key_name    = var.ssh_key_name
  aws_profile     = var.aws_profile
  aws_secret_name = var.aws_secret_name
  scripts_home    = var.scripts_home
}

resource "aws_instance" "plaid" {
  ami = module.ami_data.ami
  #   for_each = {
  #     Plaid = module.ami_data.instance_type
  #   }

  instance_type          = module.ami_data.instance_type
  key_name               = module.key_pair.ssh_key_name
  vpc_security_group_ids = [module.security.tf_sg]

  #   timeouts {
  #     create = "5m"
  #   }

  tags = {
    #  Name = each.key
    Name = var.ec2_instance_name
  }

  provisioner "file" {
    source      = "${var.scripts_home}/${local.install}"
    destination = "/tmp/${local.install}"

    connection {
      type        = local.connect.type
      host        = self.public_ip
      user        = local.connect.user
      private_key = local.connect.private_key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${local.install}",
      "/tmp/${local.install} ${var.ssh_key_name}",
      "rm -f /tmp/${local.install}",
    ]

    connection {
      type        = local.connect.type
      host        = self.public_ip
      user        = local.connect.user
      private_key = local.connect.private_key
    }
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/append_ssh_config.sh \
        ${module.key_pair.ssh_key_name} \
        ${self.public_ip} \
        ${module.ami_data.user}
      ${var.scripts_home}/start_plaid.sh \
        ${var.ssh_key_name} \
        ${self.public_ip} \
        ${module.key_pair.plaid_client_id} \
        ${module.key_pair.plaid_secret}
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    quiet      = true
    on_failure = continue
    command    = <<-EOT
      ./.terraform/modules/ec2/scripts/cleanup_ssh.sh ${self.id}
    EOT
  }
}

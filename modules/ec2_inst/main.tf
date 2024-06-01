module "security" {
  source          = "../../modules/security"
  cidr_scope      = var.cidr_scope
  extra_cidr      = var.extra_cidr
  aws_profile     = var.aws_profile
  aws_secret_name = var.aws_secret_name
}

module "ami_data" {
  source           = "../../modules/ami_data"
  ami_name_pattern = var.ami_name_pattern
  instance_type    = var.ec2_instance_type
}

module "key_pair" {
  source       = "../../modules/key_pair"
  ssh_key_name = var.ssh_key_name
  aws_profile  = var.aws_profile
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

  provisioner "remote-exec" {
    inline = module.ami_data.yum_pattern ? [
      "sudo yum update -y",
      "curl -sL https://rpm.nodesource.com/setup_20.x | sudo -E bash -",
      "sudo yum install -y nodejs",
      "echo Node",
      "node --version",
      "echo Npm",
      "npm --version",
      "sleep 10",
      "sudo yum install -y tmux",
      "sudo yum install -y git",
      "git --version",
      "git clone https://github.com/plaid/quickstart.git ${var.plaid_root_directory}",
      ] : [
      "sudo apt-get update",
      "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -",
      "sudo apt-get install nodejs -y",
      "echo Node",
      "node --version",
      "echo Npm",
      "npm --version",
      "sleep 10",
      "git clone https://github.com/plaid/quickstart.git ${var.plaid_root_directory}",
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = module.ami_data.user
      private_key = module.key_pair.private_key
    }

  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${module.key_pair.source}/append_ssh_config.sh \
        ${module.key_pair.ssh_key_name} \
        ${self.public_ip} \
        ${module.ami_data.user}
      ${path.module}/start_plaid.sh \
        ${var.ssh_key_name} \
        ${self.public_ip} \
        ${module.security.plaid_client_id} \
        ${module.security.plaid_secret}
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    quiet      = true
    on_failure = continue
    command    = <<-EOT
      aws ec2 delete-key-pair --key-name $(
        aws ec2 describe-instances --instance-ids ${self.id} \
          | jq -r '.Reservations[]|.Instances[]|.KeyName'
      )
      rm -f ~/.ssh/$( aws ec2 describe-instances --instance-ids ${self.id} \
          | jq -r '.Reservations[]|.Instances[]|.KeyName').pem
      sed -E -i -e "/^Host[[:space:]]+$(\
        aws ec2 describe-instances --instance-ids ${self.id} \
          | jq -r '.Reservations[]|.Instances[]|.KeyName')$/,/^$/d" ~/.ssh/config
      if [[ -f ~/.ssh/config_backup_tf ]]; then mv -f ~/.ssh/config_backup_tf ~/.ssh/config; fi
      rm -rf $(
        aws ec2 describe-instances --instance-ids ${self.id} \
          | jq -r '.Reservations[]|.Instances[]|.KeyName'
      )
      tmux kill-session -t $(
        aws ec2 describe-instances --instance-ids ${self.id} \
          | jq -r '.Reservations[]|.Instances[]|.KeyName'
      )
    EOT
  }
}

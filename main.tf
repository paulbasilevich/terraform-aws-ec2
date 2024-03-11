module "provider" { source = "./modules/provider" }
module "security" { source = "./modules/security" }

module "ami_data" {
  source = "./modules/ami_data"
  # ami_name = ["ubuntu-pro-server/images/hvm-ssd/ubuntu-focal-20.04-amd64-pro-server-*"]
}

# TODO: Generate key_pair as a resource, so that it could be reused at instance destroy/recreate, e.g., ami change
module "key_pair" {
  source       = "./modules/key_pair"
  ssh_key_name = "kot"
}

resource "aws_instance" "tf" {
  ami = module.ami_data.ami
  for_each = {
    tf = module.ami_data.instance_type
  }

  instance_type          = each.value
  key_name               = module.key_pair.ssh_key_name
  vpc_security_group_ids = [module.security.tf_sg]

  timeouts {
    create = "5m"
  }

  tags = {
    Name = each.key
  }

  provisioner "remote-exec" {
    inline = var.install_nginx ? startswith(module.ami_data.ami_name, "amzn2-") ? [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y nginx1",
      "sudo systemctl start nginx",
      ] : [
      "sudo apt update",
      "sudo apt install -y nginx"
    ] : ["echo -n"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = module.ami_data.user
      private_key = module.key_pair.private_key
    }

  }

  provisioner "local-exec" {
    command = <<-EOT
      ${module.key_pair.source}/append_ssh_config.sh \
        ${module.key_pair.ssh_key_name} \
        ${self.public_ip} \
        ${module.ami_data.user}
    EOT
  }

  provisioner "local-exec" {
    command = var.install_nginx && var.demo_nginx ? "open http://${aws_instance.tf["tf"].public_ip}" : "echo -n"
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
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
    EOT
  }

}


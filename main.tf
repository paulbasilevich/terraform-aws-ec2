module "provider" { source = "./modules/provider" }
module "key_pair" { source = "./modules/key_pair" }

module "security" {
  source     = "./modules/security"
  
  # vvv This setting assigns the curent host's CIDR
  # as the CIDR block of the target security group vvv 
  # cidr_scope = "my_cidr"
  cidr_scope = var.cidr_scope

  # cidr_scope = "my_host"
  # ^^^ Alternatively the above setting assigns "this-IP/32"
  # as the CIDR block of the target security group ^^^
}

module "ami_data" {
  source = "./modules/ami_data"
  ami_name = var.ami_name
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

  lifecycle {
    # ignore_changes = all
    # ignore_changes = [tags, instance_type]
    # create_before_destroy = true
    # prevent_destroy = true
  }

  # For demo purposes, the following provisioner installs nginx if one of the var's is "true"
  # Excercises the installation scenario pertaining to the AMI type in use (amazon-linux or ubuntu)
  provisioner "remote-exec" {
    inline = var.install_nginx || var.demo_nginx ? startswith(module.ami_data.ami_name, "amzn2-") ? [
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
      private_key = file("~/.ssh/${module.key_pair.ssh_key_name}_rsa")
    }

  }

  # For demo purposes, the following provisioner opens the nginx home page
  # expected to be mapped to public_ip of the host being deployed.
  provisioner "local-exec" {
    command = var.demo_nginx ? "open http://${aws_instance.tf["tf"].public_ip}" : "echo -n"
  }

  # This provisioner updates ~/.ssh/config file to provide the "simplistic" access to the target host:
  #     ssh tf
  provisioner "local-exec" {
    command = <<-EOT
      ${module.key_pair.source}/append_ssh_config.sh \
        ${module.key_pair.ssh_key_name} \
        ${self.public_ip} \
        ${module.ami_data.user}
    EOT
  }
}


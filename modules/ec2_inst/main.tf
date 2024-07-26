module "security" {
  source             = "../../modules/security"
  cidr_scope         = var.cidr_scope
  extra_cidr         = var.extra_cidr
  vpc_cidr           = var.vpc_cidr
  aws_profile        = var.aws_profile
  aws_secret_name    = var.aws_secret_name
  scripts_home       = var.scripts_home
  subnet_config      = var.subnet_config
  ec2_instance_count = local.ec2_instance_count
  backend_port       = var.backend_port
}

module "ami_data" {
  source           = "../../modules/ami_data"
  ami_name_pattern = var.ami_name_pattern
}

module "key_pair" {
  source          = "../../modules/key_pair"
  ssh_key_name    = var.ssh_key_name
  aws_profile     = var.aws_profile
  aws_secret_name = var.aws_secret_name
  scripts_home    = var.scripts_home
}

resource "aws_instance" "plaid" {
  ami                         = module.ami_data.ami
  count                       = local.ec2_instance_count
  instance_type               = module.security.subnet_config[count.index].type
  key_name                    = module.key_pair.ssh_key_name
  vpc_security_group_ids      = [module.security.security_group]
  availability_zone           = module.security.availability_zone[count.index]
  subnet_id                   = local.instance_config[count.index].snid
  tags                        = var.common_tags
  associate_public_ip_address = count.index == 0 ? true : false

  depends_on = [aws_instance.plaid[0]]

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      aws ec2 wait instance-status-ok --instance-ids ${self.id}
    EOT
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/append_ssh_config.sh \
        ${count.index} \
        ${local.ec2_instance_count} \
        ${module.key_pair.ssh_key_name} \
        ${module.ami_data.user} \
        ${self.id} \
        ${self.private_ip} \
        ${self.public_ip}
    EOT
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/upload_provision.sh \
        ${count.index} \
        ${local.ec2_instance_count} \
        ${module.key_pair.ssh_key_name} \
        ${var.scripts_home}/${local.install} \
        ${self.id}
    EOT
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/run_provision.sh \
        ${count.index} \
        ${local.ec2_instance_count} \
        ${module.key_pair.ssh_key_name} \
        ${var.scripts_home}/${local.install} \
    EOT
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_backend.sh \
        ${count.index} \
        ${local.ec2_instance_count} \
        ${var.ssh_key_name} \
        ${module.key_pair.plaid_client_id} \
        ${module.key_pair.plaid_secret}
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    quiet      = true
    on_failure = continue
    command    = startswith("${path.module}", ".terraform") ? "./.terraform/modules/ec2/scripts/cleanup_ssh.sh ${count.index} ${self.id}" : "./scripts/cleanup_ssh.sh ${count.index} ${self.id}"
  }
}

resource "aws_lb_target_group_attachment" "plaid" {
  count            = local.ec2_instance_count - 1
  target_group_arn = module.security.lb_target_group_arn
  target_id        = aws_instance.plaid[1].id
  port             = var.backend_port
}

resource "null_resource" "start_frontend_public" {
  count      = local.ec2_instance_count == 1 ? 1 : 0
  depends_on = [aws_instance.plaid[0]]
  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_frontend.sh \
        ${var.ssh_key_name} \
        ${aws_instance.plaid[0].public_dns} \
        ${var.backend_port}
    EOT
  }
}

resource "null_resource" "start_frontend_private" {
  count      = local.ec2_instance_count > 1 ? 1 : 0
  depends_on = [aws_instance.plaid[1], aws_lb_target_group_attachment.plaid[0]]
  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_frontend.sh \
        ${var.ssh_key_name} \
        ${module.security.lb_dns_name} \
        ${var.backend_port}
    EOT
  }
}


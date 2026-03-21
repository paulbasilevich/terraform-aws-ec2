module "security" {
  source            = "../../modules/security"
  cidr_scope        = var.cidr_scope
  extra_cidr        = var.extra_cidr
  vpc_cidr          = var.vpc_cidr
  aws_profile       = var.aws_profile
  scripts_home      = var.scripts_home
  subnet_config     = var.subnet_config
  backend_port      = var.backend_port
  frontend_port     = var.frontend_port
  tags_bootstrap    = var.tags_bootstrap
  deployment_subnet = var.deployment_subnet
  time_zone         = var.time_zone
}

module "ami_data" {
  source           = "../../modules/ami_data"
  ami_name_pattern = var.ami_name_pattern
}

module "key_pair" {
  source           = "../../modules/key_pair"
  ssh_key_name     = var.ssh_key_name
  aws_profile      = var.aws_profile
  scripts_home     = var.scripts_home
  plaid_external   = var.plaid_external
  common_name_root = module.security.common_name_root
}

resource "aws_instance" "pilot" {
  ami                    = module.ami_data.ami
  count                  = module.security.ec2_instance_count
  instance_type          = module.security.subnet_config[count.index].type
  key_name               = module.key_pair.ssh_key_name
  vpc_security_group_ids = [module.security.security_group]
  availability_zone      = module.security.availability_zone[count.index]
  subnet_id              = module.security.instance_config[count.index].snid
  tags = { for k, v in module.security.common_tags[count.index] :
  k => "${regex("[^-]+", "${v}")}-EC2${module.security.subnet_suffix[count.index]}" }
  associate_public_ip_address = count.index == 0 ? true : false

  depends_on = [aws_instance.pilot[0]]

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
        ${module.security.ec2_instance_count} \
        ${module.key_pair.ssh_key_name} \
        ${var.lb_suffix} \
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
        ${module.security.ec2_instance_count} \
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
        ${module.security.ec2_instance_count} \
        ${module.key_pair.ssh_key_name} \
        ${var.scripts_home}/${local.install} \
    EOT
  }

  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_backend.sh \
        ${count.index} \
        ${module.security.ec2_instance_count} \
        ${var.ssh_key_name} \
        ${module.key_pair.plaid_client_id} \
        ${module.key_pair.plaid_secret}
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    quiet      = true
    on_failure = continue
    command = "${startswith("${path.module}", ".terraform") ?
    "./.terraform/modules/ec2/scripts" : "./scripts"}/cleanup_ssh.sh ${count.index} ${self.id}"
  }
}

resource "aws_lb_target_group_attachment" "pilot" {
  count            = module.security.ec2_instance_count - 1
  target_group_arn = module.security.lb_target_group_arn
  target_id        = aws_instance.pilot[1].id
  port             = var.backend_port
}

data "external" "format_button_list" {
  depends_on = [aws_instance.pilot[0]]
  program    = ["bash", "${var.scripts_home}/format_button_list.sh"]
  query = {
    button_names = "${jsonencode(var.button_names)}"
  }
}

resource "null_resource" "start_frontend_public" {
  count      = module.security.ec2_instance_count == 1 ? 1 : 0
  depends_on = [aws_instance.pilot[0]]
  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_frontend.sh \
        ${var.ssh_key_name} \
        ${aws_instance.pilot[0].public_dns} \
        ${var.backend_port} \
        "${var.web_browser}" \
        "${var.tab_title}"
    EOT
  }
}

resource "terraform_data" "start_frontend_private" {
  count      = module.security.ec2_instance_count > 1 ? 1 : 0
  depends_on = [aws_instance.pilot[1], aws_lb_target_group_attachment.pilot[0]]
  provisioner "local-exec" {
    quiet   = true
    command = <<-EOT
      ${var.scripts_home}/start_frontend.sh \
        ${var.ssh_key_name} \
        ${module.security.lb_dns_name} \
        ${var.backend_port} \
        "${var.web_browser}" \
        "${var.tab_title}"
    EOT
  }
}


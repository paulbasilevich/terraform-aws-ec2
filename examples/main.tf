module "ec2" {
  source  = "paulbasilevich/ec2/aws"
  version = "~> 1.0"

  ami_name      = lookup(var.ami_name, terraform.workspace, local.default_ami_name)
  cidr_scope    = lookup(var.cidr_scope, terraform.workspace, local.default_cidr_scope)
  install_nginx = var.install_nginx
  demo_nginx    = var.demo_nginx
}

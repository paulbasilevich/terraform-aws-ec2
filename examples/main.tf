module "ec2" {
  source  = "paulbasilevich/ec2/aws"
  version = "1.0.2"

  ami_name      = var.ami_name[terraform.workspace]
  cidr_scope    = lookup(var.cidr_scope, terraform.workspace, "my_cidr")
  install_nginx = var.install_nginx
  demo_nginx    = var.demo_nginx
}

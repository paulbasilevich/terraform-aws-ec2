data "external" "my_cidr" {
  program = ["bash", "${path.module}/my_cidr.sh"]
  query = {
    cidr_scope = var.cidr_scope
  }
}

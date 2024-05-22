module "cidr_blk" {
  source      = "../../modules/cidr_blk"
  cidr_scope  = var.cidr_scope
  extra_cidr  = var.extra_cidr
  aws_profile = var.aws_profile
}

resource "aws_security_group" "tf_sg" {
  name        = "tf_sg"
  description = "Access from the host running TF"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.key
      to_port     = port.key
      description = port.value
      protocol    = "tcp"
      cidr_blocks = local.cidr_blocks
    }
  }

  ingress {
    from_port   = -1
    to_port     = -1
    description = "Ping"
    protocol    = "icmp"
    cidr_blocks = local.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    description = "Reach out anywhere"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TF-SG"
  }
}

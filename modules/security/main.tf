module "cidr_blk" {
  source             = "../../modules/cidr_blk"
  cidr_scope         = var.cidr_scope
  vpc_cidr           = var.vpc_cidr
  extra_cidr         = var.extra_cidr
  aws_profile        = var.aws_profile
  aws_secret_name    = var.aws_secret_name
  scripts_home       = var.scripts_home
  ec2_instance_count = var.ec2_instance_count
}

module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  subnet_config      = var.subnet_config
  common_tags        = var.common_tags
  ec2_instance_count = var.ec2_instance_count
}

resource "aws_security_group" "plaid" {
  name        = "plaid"
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

  vpc_id = module.vpc.vpc_id
  tags   = var.common_tags
}

resource "aws_lb_target_group" "plaid" {
  count       = var.ec2_instance_count - 1
  name        = "plaid"
  target_type = "instance"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 15
    path                = "/"
    interval            = 30
    matcher             = "200"
  }

  tags = var.common_tags
}

resource "aws_lb" "plaid" {
  count                      = var.ec2_instance_count - 1
  name                       = "plaid"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.plaid.id]
  subnets                    = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
  enable_deletion_protection = false
  tags                       = var.common_tags
}

resource "aws_lb_listener" "app_listener" {
  count             = var.ec2_instance_count - 1
  load_balancer_arn = aws_lb.plaid[0].arn
  port              = var.backend_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.plaid[0].arn
  }
}


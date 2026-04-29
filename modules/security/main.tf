module "vpc" {
  source            = "../../modules/vpc"
  vpc_cidr          = var.vpc_cidr
  deployment_subnet = var.deployment_subnet
  scripts_home      = var.scripts_home
  tags_bootstrap    = var.tags_bootstrap
  time_zone         = var.time_zone
}

resource "aws_security_group" "pilot" {
  name        = "pilot"
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
  tags = { for k, v in module.vpc.common_tags[0] :
  k => "${regex("[^-]+", "${v}")}-SG" }
}

resource "aws_lb_target_group" "pilot" {
  count       = module.vpc.ec2_instance_count - 1
  name        = "pilot"
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

  tags = { for k, v in module.vpc.common_tags[count.index] :
  k => "${regex("[^-]+", "${v}")}-LBTG" }
}

resource "aws_lb" "pilot" {
  count                      = module.vpc.ec2_instance_count - 1
  name                       = "pilot"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.pilot.id]
  subnets                    = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
  enable_deletion_protection = false
  tags = { for k, v in module.vpc.common_tags[count.index] :
  k => "${regex("[^-]+", "${v}")}-LB" }
}

resource "aws_lb_listener" "pilot" {
  count             = module.vpc.ec2_instance_count - 1
  load_balancer_arn = aws_lb.pilot[0].arn
  port              = var.backend_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pilot[0].arn
  }
}


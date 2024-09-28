module "provider" {
  source = "../../modules/provider"
}

resource "aws_vpc" "smirk" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.common_tags
}

data "aws_ec2_instance_type_offerings" "av_zone" {
  filter {
    name   = "instance-type"
    values = [for x in var.subnet_config : x.type]
  }
  location_type = "availability-zone"
}

resource "aws_subnet" "smirk" {
  count             = var.ec2_instance_count
  vpc_id            = aws_vpc.smirk.id
  cidr_block        = cidrsubnet(aws_vpc.smirk.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_ec2_instance_type_offerings.av_zone.locations[count.index]
  tags = {
    Name = "Smirk-Health ${var.subnet_config[count.index].role} subnet"
  }
}

resource "aws_internet_gateway" "smirk" {
  vpc_id = aws_vpc.smirk.id
  tags   = var.common_tags
}

resource "aws_eip" "smirk" {
  count      = var.ec2_instance_count - 1
  depends_on = [aws_internet_gateway.smirk]
  domain     = "vpc"
  tags       = var.common_tags
}

resource "aws_nat_gateway" "smirk" {
  count         = var.ec2_instance_count - 1
  depends_on    = [aws_internet_gateway.smirk]
  allocation_id = aws_eip.smirk[count.index].id
  subnet_id     = local.public_subnet_id
  tags          = var.common_tags
}

resource "aws_route_table" "smirk" {
  count  = var.ec2_instance_count
  vpc_id = aws_vpc.smirk.id
  tags = {
    Name = "Smirk-Health ${var.subnet_config[count.index].role} route table"
  }
}

resource "aws_route" "from_public_subnet_to_internet" {
  route_table_id         = local.public_route_table_id
  destination_cidr_block = local.cidr_out
  gateway_id             = aws_internet_gateway.smirk.id
}

resource "aws_route" "from_private_subnet_to_internet" {
  count                  = var.ec2_instance_count - 1
  route_table_id         = local.private_route_table_id
  destination_cidr_block = local.cidr_out
  nat_gateway_id         = aws_nat_gateway.smirk[count.index].id
}

resource "aws_route_table_association" "smirk-public" {
  route_table_id = local.public_route_table_id
  subnet_id      = local.public_subnet_id
}

resource "aws_route_table_association" "smirk-private" {
  count          = var.ec2_instance_count - 1
  route_table_id = local.private_route_table_id
  subnet_id      = local.private_subnet_id
}

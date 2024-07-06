module "provider" {
  source = "../../modules/provider"
}

resource "aws_vpc" "plaid" {
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

resource "aws_subnet" "plaid" {
  count             = var.ec2_instance_count
  vpc_id            = aws_vpc.plaid.id
  cidr_block        = cidrsubnet(aws_vpc.plaid.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_ec2_instance_type_offerings.av_zone.locations[count.index]
  tags = {
    Name = "Plaid ${var.subnet_config[count.index].role} subnet"
  }
}

resource "aws_internet_gateway" "plaid" {
  vpc_id = aws_vpc.plaid.id
  tags   = var.common_tags
}

resource "aws_eip" "plaid" {
  count      = var.ec2_instance_count - 1
  depends_on = [aws_internet_gateway.plaid]
  domain     = "vpc"
  tags       = var.common_tags
}

resource "aws_nat_gateway" "plaid" {
  count         = var.ec2_instance_count - 1
  depends_on    = [aws_internet_gateway.plaid]
  allocation_id = aws_eip.plaid[count.index].id
  subnet_id     = local.public_subnet_id
  tags          = var.common_tags
}

resource "aws_route_table" "plaid" {
  count  = var.ec2_instance_count
  vpc_id = aws_vpc.plaid.id
  tags = {
    Name = "Plaid ${var.subnet_config[count.index].role} route table"
  }
}

resource "aws_route" "from_public_subnet_to_internet" {
  route_table_id         = local.public_route_table_id
  destination_cidr_block = local.cidr_out
  gateway_id             = aws_internet_gateway.plaid.id
}

resource "aws_route" "from_private_subnet_to_internet" {
  count                  = var.ec2_instance_count - 1
  route_table_id         = local.private_route_table_id
  destination_cidr_block = local.cidr_out
  nat_gateway_id         = aws_nat_gateway.plaid[count.index].id
}

resource "aws_route_table_association" "plaid-public" {
  route_table_id = local.public_route_table_id
  subnet_id      = local.public_subnet_id
}

resource "aws_route_table_association" "plaid-private" {
  count          = var.ec2_instance_count - 1
  route_table_id = local.private_route_table_id
  subnet_id      = local.private_subnet_id
}

module "provider" {
  source  = "../../modules/provider"
  profile = var.aws_profile
}

data "external" "my_cidr" {
  program = ["bash", "${var.scripts_home}/my_cidr.sh"]
  query = {
    cidr_scope = var.cidr_scope
    extra_cidr = var.extra_cidr
    vpc_cidr   = local.ec2_instance_count > 1 ? cidrsubnet(var.vpc_cidr, 8, 1) : null
  }
}

resource "aws_vpc" "pilot" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { for k, v in local.common_tags[0] :
  k => "${regex("[^-]+", "${v}")}-VPC" }
}

data "aws_ec2_instance_type_offerings" "av_zone" {
  filter {
    name   = "instance-type"
    values = [for x in var.subnet_config : x.type]
  }
  location_type = "availability-zone"
}

resource "aws_subnet" "pilot" {
  count             = local.ec2_instance_count
  vpc_id            = aws_vpc.pilot.id
  cidr_block        = cidrsubnet(aws_vpc.pilot.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_ec2_instance_type_offerings.av_zone.locations[count.index]
  tags = { for k, v in local.common_tags[count.index] :
  k => "${regex("[^-]+", "${v}")}-subnet${element(local.subnet_suffix, count.index)}" }
}

resource "aws_internet_gateway" "pilot" {
  vpc_id = aws_vpc.pilot.id
  tags   = { for k, v in local.common_tags[0] : k => "${regex("[^-]+", "${v}")}-IGW" }
}

resource "aws_eip" "pilot" {
  count      = local.ec2_instance_count - 1
  depends_on = [aws_internet_gateway.pilot]
  domain     = "vpc"
  tags       = { for k, v in local.common_tags[count.index] : k => "${regex("[^-]+", "${v}")}-EIP" }
}

resource "aws_nat_gateway" "pilot" {
  count         = local.ec2_instance_count - 1
  depends_on    = [aws_internet_gateway.pilot]
  allocation_id = aws_eip.pilot[count.index].id
  subnet_id     = local.public_subnet_id
  tags          = { for k, v in local.common_tags[count.index] : k => "${regex("[^-]+", "${v}")}-NATGW" }
}

resource "aws_route_table" "pilot" {
  count  = local.ec2_instance_count
  vpc_id = aws_vpc.pilot.id
  tags = { for k, v in local.common_tags[count.index] :
  k => "${regex("[^-]+", "${v}")}-RT${element(local.subnet_suffix, count.index)}" }
}

resource "aws_route" "from_public_subnet_to_internet" {
  route_table_id         = local.public_route_table_id
  destination_cidr_block = local.cidr_out
  gateway_id             = aws_internet_gateway.pilot.id
}

resource "aws_route" "from_private_subnet_to_internet" {
  count                  = local.ec2_instance_count - 1
  route_table_id         = local.private_route_table_id
  destination_cidr_block = local.cidr_out
  nat_gateway_id         = aws_nat_gateway.pilot[count.index].id
}

resource "aws_route_table_association" "pilot-public" {
  route_table_id = local.public_route_table_id
  subnet_id      = local.public_subnet_id
}

resource "aws_route_table_association" "pilot-private" {
  count          = local.ec2_instance_count - 1
  route_table_id = local.private_route_table_id
  subnet_id      = local.private_subnet_id
}

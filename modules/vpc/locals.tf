data "external" "local_time" {
  program = ["bash", "${var.scripts_home}/check_daylight.sh"]
  query = {
    time_zone = var.time_zone
  }
}

locals {
  time_zone  = data.external.local_time.result["time_zone"]
  hour_shift = data.external.local_time.result["hour_shift"]
  time = format("%s ${local.time_zone}",
  formatdate("DD MMM YYYY hh:mm:ss", timeadd(timestamp(), "${local.hour_shift}")))
}

locals {
  cidr_blocks = split(" ", values(data.external.my_cidr.result)[0])
}

locals {
  ec2_instance_count = var.deployment_subnet == "public" ? 1 : 2
}

locals {
  c1                  = local.ec2_instance_count - 1
  public_subnet_id    = aws_subnet.pilot[0].id
  public_subnet_name  = aws_subnet.pilot[0].tags[element(keys(local.common_tags[0]), 0)]
  public_subnet_cidr  = aws_subnet.pilot[0].cidr_block
  private_subnet_id   = aws_subnet.pilot[local.c1].id
  private_subnet_name = aws_subnet.pilot[local.c1].tags[element(keys(local.common_tags[local.c1]), 0)]
  private_subnet_cidr = aws_subnet.pilot[local.c1].cidr_block

  public_route_table_id    = aws_route_table.pilot[0].id
  public_route_table_name  = aws_route_table.pilot[0].tags[element(keys(local.common_tags[0]), 0)]
  private_route_table_id   = aws_route_table.pilot[local.c1].id
  private_route_table_name = aws_route_table.pilot[local.c1].tags[element(keys(local.common_tags[local.c1]), 0)]

  cidr_out = "0.0.0.0/0"
}

locals {
  instance_config = [
    {
      role = "public"
      snid = local.public_subnet_id
      prip = join("", [regex("((\\d{1,3}.){3})", local.public_subnet_cidr)[0], "10"])
    },
    {
      role = "private"
      snid = local.private_subnet_id
      prip = join("", [regex("((\\d{1,3}.){3})", local.private_subnet_cidr)[1], "10"])
    }
  ]
}

locals {
  public_tags = {
    for k, v in var.tags_bootstrap :
    k => local.ec2_instance_count > 1 ?
    "${v}-${lookup(var.subnet_config[0], element(keys(var.subnet_config[0]), 0))}" : "${v}"
  }
}

locals {
  private_tags = {
    for k, v in var.tags_bootstrap :
    k => "${v}-${lookup(var.subnet_config[1], element(keys(var.subnet_config[1]), 0))}"
  }
}

locals {
  common_tags = [
    local.public_tags,
    local.private_tags
  ]
}

locals {
  subnet_suffix = [
    for x in local.common_tags :
    local.ec2_instance_count > 1 ?
    regex("-[^-]+", element(values(x), 0)) : ""
  ]
}


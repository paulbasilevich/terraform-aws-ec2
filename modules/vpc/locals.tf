locals {
  public_subnet_id    = aws_subnet.smirk[0].id
  public_subnet_name  = aws_subnet.smirk[0].tags["Name"]
  public_subnet_cidr  = aws_subnet.smirk[0].cidr_block
  private_subnet_id   = aws_subnet.smirk[var.ec2_instance_count - 1].id
  private_subnet_name = aws_subnet.smirk[var.ec2_instance_count - 1].tags["Name"]
  private_subnet_cidr = aws_subnet.smirk[var.ec2_instance_count - 1].cidr_block

  public_route_table_id    = aws_route_table.smirk[0].id
  public_route_table_name  = aws_route_table.smirk[0].tags["Name"]
  private_route_table_id   = aws_route_table.smirk[var.ec2_instance_count - 1].id
  private_route_table_name = aws_route_table.smirk[var.ec2_instance_count - 1].tags["Name"]

  cidr_out = "0.0.0.0/0"
}

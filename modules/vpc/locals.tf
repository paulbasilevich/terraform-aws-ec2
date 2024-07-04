locals {
  public_subnet_id    = aws_subnet.plaid[0].id
  public_subnet_name  = aws_subnet.plaid[0].tags["Name"]
  public_subnet_cidr  = aws_subnet.plaid[0].cidr_block
  private_subnet_id   = aws_subnet.plaid[var.ec2_instance_count - 1].id
  private_subnet_name = aws_subnet.plaid[var.ec2_instance_count - 1].tags["Name"]
  private_subnet_cidr = aws_subnet.plaid[var.ec2_instance_count - 1].cidr_block

  public_route_table_id    = aws_route_table.plaid[0].id
  public_route_table_name  = aws_route_table.plaid[0].tags["Name"]
  private_route_table_id   = aws_route_table.plaid[var.ec2_instance_count - 1].id
  private_route_table_name = aws_route_table.plaid[var.ec2_instance_count - 1].tags["Name"]

  cidr_out = "0.0.0.0/0"
}

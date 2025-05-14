resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { "Name" = "${local.tags["Name"]}-isolated" })
}

resource "aws_route_table_association" "isolated" {
  count = var.subnet_map["isolated"]

  subnet_id      = element(aws_subnet.isolated.*.id, count.index)
  route_table_id = aws_route_table.isolated.id
}

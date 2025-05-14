resource "aws_route_table" "private" {
  count = var.nat_instances

  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { "Name" = "${local.tags["Name"]}-private" })
}

resource "aws_route" "private_route" {
  count                  = var.nat_instances
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count = var.subnet_map["private"]

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

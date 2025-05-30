resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, { "Name" = "${local.tags["Name"]}-public" })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = var.subnet_map["public"]

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

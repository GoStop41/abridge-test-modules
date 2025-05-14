resource "aws_eip" "nat" {
  count = var.nat_instances
  vpc   = "true"

  tags = local.tags
}

resource "aws_nat_gateway" "main" {
  count = var.nat_instances

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = local.tags
}

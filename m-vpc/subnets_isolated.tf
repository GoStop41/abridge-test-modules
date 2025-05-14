resource "aws_subnet" "isolated" {
  count = var.subnet_map["isolated"]

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, var.newbits["isolated"], count.index + var.netnum_shift_map["isolated"])

  availability_zone       = element(data.aws_availability_zones.main.names, count.index % var.az_width)
  map_public_ip_on_launch = "false"

  tags = merge(local.tags,
    { "Name" = "${local.tags["Name"]}-isolated"
    },
    var.subnets_tags.subnets_isolated
  )
  lifecycle {
    ignore_changes = [tags]
  }
}
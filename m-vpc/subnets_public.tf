resource "aws_subnet" "public" {
  count = var.subnet_map["public"]

  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.cidr_block, var.newbits["public"], count.index + var.netnum_shift_map["public"])

  availability_zone       = element(data.aws_availability_zones.main.names, count.index % var.az_width)
  map_public_ip_on_launch = "true"

  tags = merge(local.tags,
    { "Name" = "${local.tags["Name"]}-public"
    },
    var.subnets_tags.subnets_public
  )
  lifecycle {
    ignore_changes = [tags]
  }
}

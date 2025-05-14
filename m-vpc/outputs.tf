output "id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "default_nacl" {
  value = aws_vpc.main.default_network_acl_id
}

output "sg_default" {
  value = aws_vpc.main.default_security_group_id
}

output "subnets_public" {
  value = aws_subnet.public.*.id
}

output "subnets_private" {
  value = aws_subnet.private.*.id
}

output "subnets_isolated" {
  value = aws_subnet.isolated.*.id
}

output "routes_public" {
  value = aws_route_table.public.*.id
}

output "routes_private" {
  value = aws_route_table.private.*.id
}

output "routes_isolated" {
  value = aws_route_table.isolated.*.id
}

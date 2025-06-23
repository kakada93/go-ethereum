output "vpc" {
  value = aws_vpc.vpc
}

output "private_route_tables" {
  value = aws_route_table.private[*]
}

output "public_subnet" {
  value = aws_subnet.public_subnet[*]
}

output "private_subnet" {
  value = aws_subnet.private_subnet[*]
}

## Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(var.global_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(var.global_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gw.id
}

resource "aws_route" "peering_routes_public" {
  for_each                  = var.vpc_peering_connections_sameregion

  route_table_id            = aws_vpc.vpc.main_route_table_id
  destination_cidr_block    = each.value["peer_cidr_block"]
  vpc_peering_connection_id = aws_vpc_peering_connection.same_region_peering[each.key].id
}

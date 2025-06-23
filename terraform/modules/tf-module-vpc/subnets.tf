# ---------------------------------------------------------------------------------------------------------------------
# AWS Subnets - Public
# ---------------------------------------------------------------------------------------------------------------------
# Subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = var.enable_public_ip_autoassign
  tags = merge(
    var.global_tags,
    { "Name" = "${var.name_prefix}-public-subnet-${count.index}" },
    { "type" = "public" },
    var.public_subnet_tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Subnets - Private
# ---------------------------------------------------------------------------------------------------------------------
# Elastic IP for the Nat Gateways
resource "aws_eip" "elastic_ip" {
  count = var.enable_private_network ? ( var.enable_nat_gateways ? length(var.availability_zones) : 0 ) : 0
  vpc   = true
  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-natgw-eip-${count.index}" }
  )
}

# Nat Gateways
resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_private_network ? ( var.enable_nat_gateways ? length(var.availability_zones) : 0 ) : 0
  subnet_id     = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.elastic_ip[count.index].id
  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-ngw-${count.index}" }
  )
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count                   = var.enable_private_network ? length(var.availability_zones) : 0
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.availability_zones, count.index)
  cidr_block              = element(var.private_subnets_cidrs, count.index)
  map_public_ip_on_launch = false
  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-private-subnet-${count.index}" },
    { "type" = "private" },
    var.private_subnet_tags,
  )
}


## Setup interconnect between the private and public subnets
resource "aws_route_table" "private" {
  count  = var.enable_private_network ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-route-tbl-${count.index}" },
  )
}

resource "aws_route_table_association" "private" {
  count          = var.enable_private_network ? length(var.availability_zones) : 0
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

resource "aws_route" "private_defroute" {
  count  = var.enable_private_network ? length(var.availability_zones) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.enable_nat_gateways ? aws_nat_gateway.nat_gw[count.index].id : null
  gateway_id     = var.enable_nat_gateways ? null : aws_internet_gateway.internet_gw.id
}

locals {
  peering_conns_private_routes = flatten([
      for key, value in var.vpc_peering_connections_sameregion: [
          for idx in var.availability_zones: {
              conn_id    = key
              cidr       = value["peer_cidr_block"]
              subnet_idx = index(var.availability_zones, idx)
          }
      ]
  ])

  extra_private_routes = flatten([
      for key, value in var.extra_private_routes: [
          for idx in var.availability_zones: {
              conn_id                   = key
              cidr                      = value["remote_cidr"]
              subnet_idx                = index(var.availability_zones, idx)
              nat_gateway_id            = lookup(value, "nat_gateway_id", null)
              gateway_id                = lookup(value, "gateway_id", null)
              vpc_peering_connection_id = lookup(value, "vpc_peering_connection_id", null)
              network_interface_id      = lookup(value, "network_interface_id", null)
          }
      ]
  ])
}

resource "aws_route" "private_vpc_peering_routes" {
  count                     = var.enable_private_network ? length(local.peering_conns_private_routes) : 0

  route_table_id            = aws_route_table.private[local.peering_conns_private_routes[count.index].subnet_idx].id
  destination_cidr_block    = local.peering_conns_private_routes[count.index].cidr

  vpc_peering_connection_id = aws_vpc_peering_connection.same_region_peering[local.peering_conns_private_routes[count.index].conn_id].id
}

resource "aws_route" "extra_private_routes" {
  count                     = var.enable_private_network ? length(local.extra_private_routes) : 0

  route_table_id            = aws_route_table.private[local.extra_private_routes[count.index].subnet_idx].id
  destination_cidr_block    = local.extra_private_routes[count.index].cidr

  nat_gateway_id            = lookup(local.extra_private_routes[count.index], "nat_gateway_id", null)
  gateway_id                = lookup(local.extra_private_routes[count.index], "gateway_id", null)
  vpc_peering_connection_id = lookup(local.extra_private_routes[count.index], "vpc_peering_connection_id", null)
  network_interface_id      = lookup(local.extra_private_routes[count.index], "network_interface_id", null)
}

resource "aws_route" "extra_public_routes" {
  for_each                  = var.extra_public_routes
  route_table_id            = aws_vpc.vpc.main_route_table_id

  destination_cidr_block    = each.value["remote_cidr"]

  nat_gateway_id            = lookup(each.value, "nat_gateway_id", null)
  gateway_id                = lookup(each.value, "gateway_id", null)
  vpc_peering_connection_id = lookup(each.value, "vpc_peering_connection_id", null)
  network_interface_id      = lookup(each.value, "network_interface_id", null)
}

resource "aws_vpc_peering_connection" "same_region_peering" {
  for_each      = var.vpc_peering_connections_sameregion

  vpc_id        = aws_vpc.vpc.id

  peer_vpc_id   = each.value["peer_vpc_id"]

  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = each.value["remote_dns_resolution"]
  }
  requester {
    allow_remote_vpc_dns_resolution = each.value["remote_dns_resolution"]
  }

  tags = merge(
    var.global_tags,
    { Name = "VPC Peering between ${aws_vpc.vpc.id} and ${each.value.peer_vpc_id}" }
  )
}

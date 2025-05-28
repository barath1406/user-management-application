##################################################################################
###                     VPC PEERING CONNECTION REQUESTER                       ###
##################################################################################
resource "aws_vpc_peering_connection" "requester" {
  count = var.enabled ? 1 : 0

  vpc_id        = var.requester_vpc_id
  peer_owner_id = var.accepter_account_id
  peer_vpc_id   = var.accepter_vpc_id
  peer_region   = var.accepter_region_id
  auto_accept   = false
  provider      = aws.default

  tags = merge(
    var.tags,
    {
      "Name" = var.peering_name
    },
  )
}

##################################################################################
###                          VPC PEERING CONNECTION ACCEPTER                   ###
##################################################################################
resource "aws_vpc_peering_connection_accepter" "accepter" {
  count = var.enabled ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  auto_accept               = true

  tags = merge(
    var.tags,
    {
      "Name" = var.peering_name
    },
  )
}

##################################################################################
###       ROUTE TABLES FOR ROUTING TRAFFIC BETWEEN REQUESTER AND ACCEPTER      ###
##################################################################################

resource "aws_route" "requester_vpc" {
  count = var.enabled ? 1 : 0

  route_table_id            = element(var.requester_vpc_rt_id, 0)
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  provider                  = aws.default
}

resource "aws_route" "requester_public_route" {
  count = var.enabled ? 1 : 0

  route_table_id            = element(var.requester_vpc_public_rt_ids, 0)
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  provider                  = aws.default
}

# Route from the requester’s private subnets to the accepter VPC through the peering connection.
resource "aws_route" "requester_private_route" {
  count = (var.enabled ? 1 : 0) * length(var.requester_vpc_private_rt_ids)

  route_table_id            = element(var.requester_vpc_private_rt_ids, count.index)
  destination_cidr_block    = var.accepter_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
  provider                  = aws.default
}

# Route from the accepter VPC to the requester’s private subnets using the peering connection.
resource "aws_route" "accepter_private_route" {
  count = var.accepter_private_rt_count * (var.enabled ? 1 : 0)

  route_table_id            = element(var.accepter_vpc_private_rt_ids, count.index)
  destination_cidr_block    = var.requester_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.requester[0].id
}

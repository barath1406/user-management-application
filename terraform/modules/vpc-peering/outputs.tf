##################################################################################
# OUTPUT: VPC Peering Connection ID
##################################################################################

output "peer_id" {
  description = "VPC peering connection ID"
  value       = aws_vpc_peering_connection.requester[*].id
}

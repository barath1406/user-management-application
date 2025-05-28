##################################################################################
### Outputs for Security Group                                                 ###
##################################################################################

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.aws_sg.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.aws_sg.name
}

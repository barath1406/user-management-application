##################################################################################
### Outputs of Bastion EC2 Instance ###
##################################################################################

output "instance_id" {
  value = aws_instance.bastion.id # The ID of the Bastion EC2 instance
}

output "public_ip" {
  value = aws_instance.bastion.public_ip # The public IP of the Bastion EC2 instance
}

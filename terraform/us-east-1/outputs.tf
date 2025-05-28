##################################################################################
###                              WAF Module Outputs                            ### 
##################################################################################

output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = module.waf.web_acl_id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = module.waf.web_acl_arn
}

output "ip_set_arn" {
  description = "The ARN of the IP set for whitelisted IPs"
  value       = module.waf.ip_set_arn
}

##################################################################################
###                              VPC1 Module Outputs                           ### 
##################################################################################

output "vpc1_private_subnets" {
  description = "A list of private subnet IDs for VPC1"
  value       = module.vpc1.private_subnets
}

output "vpc1_public_subnets" {
  description = "A list of public subnet IDs for VPC1"
  value       = module.vpc1.public_subnets
}

output "vpc1_vpc_id" {
  description = "The VPC ID for VPC1"
  value       = module.vpc1.vpc_id
}

output "vpc1_vpc_cidr_block" {
  description = "The CIDR block of VPC1"
  value       = module.vpc1.vpc_cidr_block
}

output "vpc1_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with VPC1"
  value       = module.vpc1.vpc_main_route_table_id
}

output "vpc1_default_route_table_id" {
  description = "The ID of the default route table in VPC1"
  value       = module.vpc1.default_route_table_id
}

output "vpc1_public_route_table_ids" {
  description = "Route tables used by public subnets in VPC1"
  value       = module.vpc1.public_route_table_ids
}

output "vpc1_private_route_table_ids" {
  description = "Route tables used by private subnets in VPC1"
  value       = module.vpc1.private_route_table_ids
}

output "vpc1_default_security_group_id" {
  description = "The default security group created in VPC1"
  value       = module.vpc1.default_security_group_id
}

output "vpc1_nat_eips" {
  description = "Allocation IDs of NAT Gateway EIPs in VPC1"
  value       = module.vpc1.nat_eips
}

output "vpc1_nat_eips_public_dns" {
  description = "Public DNS names of NAT Gateways in VPC1"
  value       = module.vpc1.nat_eips_public_dns
}

output "vpc1_nat_eips_public_ips" {
  description = "Public IPs of NAT Gateways in VPC1"
  value       = module.vpc1.nat_eips_public_ips
}

output "vpc1_nat_eips_private_ips" {
  description = "Private IPs of NAT Gateways in VPC1"
  value       = module.vpc1.nat_eips_private_ips
}

output "vpc1_natgw_ids" {
  description = "IDs of NAT Gateways in VPC1"
  value       = module.vpc1.natgw_ids
}

output "vpc1_igw_id" {
  description = "ID of the Internet Gateway in VPC1"
  value       = module.vpc1.igw_id
}

output "vpc1_vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block of VPC1"
  value       = module.vpc1.vpc_ipv6_cidr_block
}

output "vpc1_vpc_ipv6_association_id" {
  description = "Association ID for the IPv6 CIDR block in VPC1"
  value       = module.vpc1.vpc_ipv6_association_id
}

##################################################################################
###                              VPC2 Module Outputs                           ### 
##################################################################################

output "vpc2_private_subnets" {
  description = "A list of private subnet IDs for VPC2"
  value       = module.vpc2.private_subnets
}

output "vpc2_public_subnets" {
  description = "A list of public subnet IDs for VPC2"
  value       = module.vpc2.public_subnets
}

output "vpc2_vpc_id" {
  description = "The VPC ID for VPC2"
  value       = module.vpc2.vpc_id
}

output "vpc2_vpc_cidr_block" {
  description = "The CIDR block of VPC2"
  value       = module.vpc2.vpc_cidr_block
}

output "vpc2_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with VPC2"
  value       = module.vpc2.vpc_main_route_table_id
}

output "vpc2_default_route_table_id" {
  description = "The ID of the default route table in VPC2"
  value       = module.vpc2.default_route_table_id
}

output "vpc2_public_route_table_ids" {
  description = "Route tables used by public subnets in VPC2"
  value       = module.vpc2.public_route_table_ids
}

output "vpc2_private_route_table_ids" {
  description = "Route tables used by private subnets in VPC2"
  value       = module.vpc2.private_route_table_ids
}

output "vpc2_default_security_group_id" {
  description = "The default security group created in VPC2"
  value       = module.vpc2.default_security_group_id
}

output "vpc2_nat_eips" {
  description = "Allocation IDs of NAT Gateway EIPs in VPC2"
  value       = module.vpc2.nat_eips
}

output "vpc2_nat_eips_public_dns" {
  description = "Public DNS names of NAT Gateways in VPC2"
  value       = module.vpc2.nat_eips_public_dns
}

output "vpc2_nat_eips_public_ips" {
  description = "Public IPs of NAT Gateways in VPC2"
  value       = module.vpc2.nat_eips_public_ips
}

output "vpc2_nat_eips_private_ips" {
  description = "Private IPs of NAT Gateways in VPC2"
  value       = module.vpc2.nat_eips_private_ips
}

output "vpc2_natgw_ids" {
  description = "IDs of NAT Gateways in VPC2"
  value       = module.vpc2.natgw_ids
}

output "vpc2_igw_id" {
  description = "ID of the Internet Gateway in VPC2"
  value       = module.vpc2.igw_id
}

output "vpc2_vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block of VPC2"
  value       = module.vpc2.vpc_ipv6_cidr_block
}

output "vpc2_vpc_ipv6_association_id" {
  description = "Association ID for the IPv6 CIDR block in VPC2"
  value       = module.vpc2.vpc_ipv6_association_id
}

##################################################################################
###                              VPC Peering Outputs                           ### 
##################################################################################

output "vpc_peering_peer_id" {
  description = "VPC peering connection ID"
  value       = module.vpc_peering.peer_id
}

##################################################################################
###                               EKS Cluster Outputs                          ### 
##################################################################################

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_name" {
  description = "The name/id of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

##################################################################################
###                            EKS Security Group Outputs                      ### 
##################################################################################

output "eks_cluster_sg_id" {
  description = "ID of the EKS cluster security group"
  value       = module.eks_cluster_sg.security_group_id
}

output "eks_cluster_sg_name" {
  description = "Name of the EKS cluster security group"
  value       = module.eks_cluster_sg.security_group_name
}

output "eks_nodegroup_sg_id" {
  description = "ID of the EKS nodegroup security group"
  value       = module.eks_nodegroup_sg.security_group_id
}

output "eks_nodegroup_sg_name" {
  description = "Name of the EKS nodegroup security group"
  value       = module.eks_nodegroup_sg.security_group_name
}

##################################################################################
###                              EKS Nodegroup Outputs                         ### 
##################################################################################

output "eks_nodegroup_launch_template_name" {
  description = "Name of the EKS launch template"
  value       = module.eks_nodegroup.launch_template_name
}

output "eks_nodegroup_launch_template_latest_version" {
  description = "Latest version of the EKS launch template"
  value       = module.eks_nodegroup.launch_template_latest_version
}

##################################################################################
###                                Aurora MySQL Outputs                        ### 
##################################################################################

output "aurora_mysql_cluster_id" {
  description = "ID of the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_id
}

output "aurora_mysql_cluster_endpoint" {
  description = "Endpoint of the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_endpoint
}

output "aurora_mysql_cluster_reader_endpoint" {
  description = "Reader endpoint of the Aurora cluster"
  value       = module.aurora_mysql.cluster_reader_endpoint
}

output "aurora_mysql_cluster_port" {
  description = "Port the Aurora cluster listens on"
  value       = module.aurora_mysql.cluster_port
}

output "aurora_mysql_cluster_instance_ids" {
  description = "IDs of Aurora DB instances"
  value       = module.aurora_mysql.cluster_instance_ids
}

output "aurora_mysql_cluster_arn" {
  description = "ARN of the Aurora MySQL cluster"
  value       = module.aurora_mysql.cluster_arn
}

output "aurora_mysql_database_name" {
  description = "Database name"
  value       = module.aurora_mysql.database_name
}

output "aurora_mysql_secret_arn" {
  description = "Secrets Manager ARN for DB credentials"
  value       = module.aurora_mysql.secret_arn
}

output "aurora_mysql_secret_name" {
  description = "Secrets Manager name for DB credentials"
  value       = module.aurora_mysql.secret_name
}

output "aurora_mysql_subnet_group_id" {
  description = "Subnet group ID for Aurora MySQL"
  value       = module.aurora_mysql.subnet_group_id
}

output "aurora_mysql_cluster_parameter_group_id" {
  description = "Cluster parameter group ID"
  value       = module.aurora_mysql.cluster_parameter_group_id
}

output "aurora_mysql_parameter_group_id" {
  description = "Parameter group ID for Aurora DB instances"
  value       = module.aurora_mysql.parameter_group_id
}

##################################################################################
###                             DB Security Group Outputs                      ### 
##################################################################################

output "db_security_group_id" {
  description = "ID of the DB security group"
  value       = module.db_security_group.security_group_id
}

output "db_security_group_name" {
  description = "Name of the DB security group"
  value       = module.db_security_group.security_group_name
}

##################################################################################
###                                  Lambda Outputs                            ### 
##################################################################################

output "lambda_log_group_name" {
  description = "CloudWatch Log Group name for Lambda function"
  value       = module.lambda_function.lambda_log_group_name
}

output "lambda_sg_id" {
  description = "ID of the Lambda security group"
  value       = module.lambda_sg.security_group_id
}

output "lambda_sg_name" {
  description = "Name of the Lambda security group"
  value       = module.lambda_sg.security_group_name
}

##################################################################################
###                                 S3 Bucket Outputs                          ### 
##################################################################################

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

##################################################################################
###                              Bastion Host Outputs                          ### 
##################################################################################

output "bastion_instance_id" {
  description = "EC2 instance ID of the Bastion host"
  value       = module.bastion.instance_id
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = module.bastion.public_ip
}

output "bastion_sg_id" {
  description = "Security group ID for the Bastion host"
  value       = module.bastion_sg.security_group_id
}

output "bastion_sg_name" {
  description = "Security group name for the Bastion host"
  value       = module.bastion_sg.security_group_name
}

##################################################################################
###                                    ALB Outputs                             ### 
##################################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer for Route 53 alias records"
  value       = module.alb.alb_zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}
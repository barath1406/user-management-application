###################################################
# Environment Specific Configurations
###################################################

# Global Environment Settings
environment                       = "development"
enabled                           = true
region                            = "us-west-2"

# Common Tags for All Resources
tags                              = {
  "Owner"                         = "SRE Team"
  "Environment"                   = "development"
  "AWSRegion"                     = "Frankfurt"
  "Organization"                  = "barath SE"
}

###################################################
# VPC Configuration
###################################################

# VPC Settings
vpc1_name                         = "barath-compute-vpc-"
vpc1_cidr                         = "10.5.0.0/16"
vpc2_name                         = "barath-db-vpc-"
vpc2_cidr                         = "10.10.0.0/16"
availability_zones                = ["us-east-1a", "us-east-1b"]
enable_nat_gateway                = true
enable_s3_endpoint                = true
peering_name                      = "vpc1-to-vpc2-peering"

# DNS & IP Configuration
enable_dns_hostnames              = true
enable_dns_support                = true
enable_ipv6                       = false
assign_ipv6_address_on_creation   = false
map_public_ip_on_launch           = true
private_subnet_newbits            = "4"
public_subnet_newbits             = "8"

# Bastion Host Whitelist
bastion_host_whitelist            = ["10.10.0.0/16"]

###################################################
# Subnet Tags
###################################################

public_subnet_tags                = {
  Tier                            = "Public"
}
alb_controller_public_subnet_tags = {
  "kubernetes.io/role/elb"        = "1",
  "kubernetes.io/cluster/barath-eks" = "owned"
}
private_subnet_tags               = {
  Tier                            = "Private"
}

###################################################
# Bastion Host Configuration
###################################################

bastion_name                      = "barath-bastion-ec2"
bastion_key_name                  = "barath-bastion-key"
bastion_instance_type             = "t3.micro"
bastion_host_iam_role             = "barath-bastion-host-role"
bastion_sg_name                   = "barath-bastion-ec2-sg"
bastion_sg_description            = "Security group for bastion host allowing SSH access"
bastion_patch_group_tags          = {
  "Patch Group"                   = "Linux"
}
associate_public_ip_address       = true
private_key_file_permission       = "0400"
kms_key_arn                       = "null"
bastion_sg_ingress_rules          = [
  {
    description                   = "SSH from anywhere"
    ip_protocol                   = "tcp"
    from_port                     = 22
    to_port                       = 22
    cidr_ipv4                     = "0.0.0.0/0"
  }
]
bastion_sg_egress_rules           = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]

###################################################
# Lambda Configuration
###################################################

lambda_function_name              = "barath-data-vpc-lambda"
lambda_iam_role_name              = "barath-lambda-execution-role-data-vpc"
lambda_handler                    = "import.lambda_handler"
lambda_runtime                    = "python3.9"
lambda_source_path                = "../../serverless/lambda/"
lambda_timeout                    = "900"
log_group_retention_in_days       = "30"
lambda_sg_name                    = "barath-data-vpc-lambda-sg"
lambda_sg_description             = "Security group for Lambda"
lambda_sg_ingress_rules           = [
  {
    description                   = "Allow Data VPC"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "10.10.0.0/16"
  }
]
lambda_sg_egress_rules            = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]
s3_prefix                         = "data-sets/"
s3_suffix                         = ".csv"
schedule_expression               = "cron(0 0 * * ? *)"

###################################################
# EKS Cluster Configuration
###################################################

create_eks_cluster                = true
eks_cluster_name                  = "barath-eks"
eks_cluster_version               = "1.31"
eks_type                          = "cluster"
eks_cluster_iam_role              = "barath-eks-cluster-role"
eks_cluster_sg_name               = "barath-eks-cluster-server-sg"
eks_cluster_sg_description        = "Security group for EKS cluster"
eks_enabled_log_types             = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
eks_endpoint_private_access       = true
eks_endpoint_public_access        = true
eks_public_access_cidrs           = ["49.47.243.104/32", "223.185.26.131/32"]
eks_network_config                = "172.20.0.0/16"
client_id_list                    = ["sts.amazonaws.com"]
thumbprint_list                   = ["06b25927c42a721631c1efd9431e648fa62e1e39"]
eks_admin_policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
authentication_mode               = "API_AND_CONFIG_MAP"
user_access                       = "challenge_barathkumar"
eks_cluster_sg_ingress_rules      = [
  {
    description                   = "Allow Compute VPC"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "10.5.0.0/16"
  },
  {
    description                   = "Allow Data VPC"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "10.10.0.0/16"
  }
]
eks_cluster_sg_egress_rules       = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]

###################################################
# EKS Node Group Configuration
###################################################

eks_node_ami                      = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id"
eks_node_group_name               = "development-workers"
eks_node_name                     = "worker-node"
eks_nodegroup_iam_role            = "barath-eks-node-group-role"
eks_node_group_instance_type      = "t3.medium"
ami_type                          = "CUSTOM"
resource_type                     = "instance"
eks_node_group_disk_size          = 100
eks_node_group_capacity_type      = "ON_DEMAND"
eks_node_group_min_size           = 2
eks_node_group_max_size           = 2
eks_node_group_desired_size       = 2
eks_node_key_name                 = "eks-node-key"
eks_node_group_launch_template_name = "barath-nodegroup-lt"
device_name                       = "/dev/xvda"
delete_on_termination             = true
volume_size                       = 30
volume_type                       = "gp2"
http_put_response_hop_limit       = 2
http_endpoint                     = "enabled"
http_tokens                       = "optional"
eks_patch_group_tags              = {
  "Patch Group"                   = "WorkerNode"
}
eks_node_group_labels             = {
  "role"                          = "worker"
  "environment"                   = "development"
}
eks_nodegroup_sg_name             = "barath-eks-nodegroup-server-sg"
eks_nodegroup_sg_description      = "Security group for EKS Node group"
eks_nodegroup_sg_ingress_rules    = [
  {
    description                   = "Allow Compute VPC"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "10.5.0.0/16"
  },
  {
    description                   = "Allow Data VPC"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "10.10.0.0/16"
  }
]
eks_nodegroup_sg_egress_rules     = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]

###################################################
# IRSA Policy for User Portal
###################################################

irsa_user_portal_policy_name      = "barath-irsa-user-portal-policy"
irsa_user_portal_policy_description = "IAM policy for accessing Aurora secrets and KMS decrypt"
irsa_user_portal_role_name        = "barath-user-portal-role"
eks_cluster_iam_role_path         = "/"

###################################################
# S3 Bucket Configuration
###################################################

bucket_name                       = "sre-falcon-secure-files"
acl                               = "private"
object_ownership                  = "BucketOwnerPreferred"

###################################################
# RDS (Aurora) Configuration
###################################################

cluster_identifier                = "barath-aurora-cluster"
database_name                     = "mydb"
master_username                   = "admin"
rds_monitoring_role               = "barath-rds-role"
rds_db_sg_name                    = "aurora-security-group"
rds_db_sg_description             = "Security group for Aurora MySQL cluster"
monitoring_interval               = "60"
create_random_password            = true
rds_db_sg_ingress_rules           = [
  {
    description                   = "Allow Data VPC"
    ip_protocol                   = "tcp"
    from_port                     = 3306
    to_port                       = 3306
    cidr_ipv4                     = "0.0.0.0/0"
  }
]
rds_db_sg_egress_rules            = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]
engine_version                    = "8.0.mysql_aurora.3.05.2"
engine                            = "aurora-mysql"
preferred_backup_window           = "02:00-03:00"
preferred_maintenance_window      = "sun:05:00-sun:06:00"
instance_class                    = "db.t3.medium"
parameter_group_family            = "aurora-mysql8.0"
secrets_recovery_window_in_days   = 7
backup_retention_period           = 7
port                              = 3306
storage_encrypted                 = true
kms_key_id                        = null
instance_count                    = 2
cluster_parameters                = []
instance_parameters               = []
deletion_protection               = true
skip_final_snapshot               = false
publicly_accessible               = false
apply_immediately                 = false
auto_minor_version_upgrade        = true
enabled_cloudwatch_logs_exports   = ["audit", "error", "general", "slowquery"]
performance_insights_enabled      = false
iam_database_authentication_enabled = false

###################################################
# ALB Controller Configuration
###################################################
app_namespace                     = "barath"
user_portal_alb_name              = "barath-eks-alb"

# ALB Configuration
enable_alb_deletion_protection    = true
acm_certificate_arn               = "arn:aws:acm:us-east-1:1234567890:certificate/0d69fdac-221c-4dac-a064-58478f35a430"

# Target Group Configuration
target_group_port                 = 30443
https_protocol                    = "HTTPS"
https_port                        = 443
internal_alb                      = false
health_check_path                 = "/healthz"
health_check_port                 = 30080
health_check_interval             = 30
health_check_timeout              = 5
health_check_healthy_threshold    = 3
health_check_unhealthy_threshold  = 3
health_check_matcher              = "200"

# HTTPS Listener Configuration
ssl_policy                        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

# Security Group Configuration
alb_sg_description                = "Security group for App ALB SG"
alb_sg_ingress_rules              = [
  {
    description                   = "Allow Internet CIDR1"
    ip_protocol                   = "tcp"
    from_port                     = 443
    to_port                       = 443
    cidr_ipv4                     = "0.0.0.0/1"
  },
  {
    description                   = "Allow Internet CIDR2"
    ip_protocol                   = "tcp"
    from_port                     = 443
    to_port                       = 443
    cidr_ipv4                     = "128.0.0.0/1"
  }
]
alb_sg_egress_rules               = [
  {
    description                   = "Allow required outbound traffic"
    ip_protocol                   = "-1"
    cidr_ipv4                     = "0.0.0.0/0"
  }
]

###################################################
# Route53 Configuration
###################################################

route53_zone_name                 = "barath.network"
record_type                       = "A"
evaluate_target_health            = true

###################################################
# WAF Configuration
###################################################

waf_name                          = "barath-eks-alb-waf"
waf_description                   = "WAF to protect barath User Portal ALB - Allows only whitelisted IPs and implements AWS managed rules for protection against common threats"
whitelist_ips                     = ["49.47.243.104/32", "223.185.26.131/32"]
ip_set_name                       = "barath-whitelisted-ips"
ip_set_description                = "IP set for whitelisted IPs to access the ALB"
metrics_enabled                   = true
sampled_requests                  = true
default_action                    = "allow"

# WAF Rules
rule_whitelist_name               = "allow-whitelisted-ips"
rule_ip_rep_name                  = "aws-ip-reputation-list"
rule_anon_ip_name                 = "aws-anonymous-ip-list"
rule_sqli_name                    = "aws-sqli-rule-set"

# WAF Metrics
metric_whitelist_name             = "block-global-world"
metric_ip_rep_name                = "AWSManagedRulesAmazonIpReputationList"
metric_anon_ip_name               = "AWSManagedRulesAnonymousIpList"
metric_sqli_name                  = "AWSManagedRulesSQLiRuleSet"
metric_waf_name                   = "WAFWebACL"

###################################################
# User Portal App Configuration
###################################################

app_service_account_name          = "barath-user-portal-sa"
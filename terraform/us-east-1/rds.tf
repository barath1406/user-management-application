##################################################################################
###                           Module: Aurora RDS (MySQL)                       ### 
##################################################################################
module "aurora_mysql" {
  source                              = "../modules/rds-aurora/"
  cluster_identifier                  = var.cluster_identifier
  database_name                       = var.database_name
  master_username                     = var.master_username
  create_random_password              = var.create_random_password
  subnet_ids                          = ["subnet-040634ef5da86495c","subnet-06bf1e1fb9cc449e3","subnet-0a186fb0da9f0f44a"]
  security_group_ids                  = [module.db_security_group.security_group_id]
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = data.aws_iam_role.rds_monitoring_role.arn
  engine_version                      = var.engine_version
  engine                              = var.engine
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  instance_class                      = var.instance_class
  parameter_group_family              = var.parameter_group_family
  secrets_recovery_window_in_days     = var.secrets_recovery_window_in_days
  backup_retention_period             = var.backup_retention_period
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  port                                = var.port
  cluster_parameters                  = var.cluster_parameters
  instance_parameters                 = var.instance_parameters
  instance_count                      = var.instance_count
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  publicly_accessible                 = var.publicly_accessible
  apply_immediately                   = var.apply_immediately
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled        = var.performance_insights_enabled
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  tags = var.tags
}

##################################################################################
###                        Module: Security Group for RDS DB                   ### 
##################################################################################
module "db_security_group" {
  source         = "../modules/sg"
  sg_name        = var.rds_db_sg_name
  sg_description = var.rds_db_sg_description
  vpc_id         = "vpc-07fc414f341d85ff9"
  ingress_rules  = var.rds_db_sg_ingress_rules
  egress_rules   = var.rds_db_sg_egress_rules

  tags = var.tags
}
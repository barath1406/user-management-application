##################################################################################
###                       Module: Lambda Function Deployment                   ### 
##################################################################################
module "lambda_function" {
  source             = "../modules/lambda"
  function_name      = var.lambda_function_name
  handler            = var.lambda_handler
  runtime            = var.lambda_runtime
  source_zip         = data.archive_file.lambda_zip.output_path
  use_default_kms    = var.enabled
  kms_key_arn        = var.kms_key_arn
  vpc_id             = module.vpc2.vpc_id
  subnet_ids         = module.vpc2.private_subnets
  security_group_ids = [module.lambda_sg.security_group_id]
  vpc_cidr_block     = module.vpc2.vpc_cidr_block
  environment_variables = {
    DB_HOST     = module.aurora_mysql.cluster_endpoint
    DB_USER     = var.master_username
    SECRET_NAME = module.aurora_mysql.secret_name
    S3_BUCKET   = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  }
  iam_role_arn                = data.aws_iam_role.lambda_role.arn
  log_group_retention_in_days = var.log_group_retention_in_days
  lambda_timeout              = var.lambda_timeout
  bucket_name                 = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
  s3_prefix                   = var.s3_prefix
  s3_suffix                   = var.s3_suffix
  schedule_expression         = var.schedule_expression

  tags = var.tags
}

##################################################################################
###                         Module: Lambda Security Group                      ### 
##################################################################################
module "lambda_sg" {
  source         = "../modules/sg"
  sg_name        = var.lambda_sg_name
  sg_description = var.lambda_sg_description
  vpc_id         = module.vpc2.vpc_id
  ingress_rules  = var.lambda_sg_ingress_rules
  egress_rules   = var.lambda_sg_egress_rules

  tags = var.tags
}
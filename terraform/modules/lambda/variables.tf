##################################################################################
###                            Variables of Lambda                             ###
##################################################################################

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
}

variable "source_zip" {
  description = "Path to the Lambda deployment package zip file"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Lambda will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block where Lambda will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "iam_role_arn" {
  description = "IAM Role ARN for Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "use_default_kms" {
  description = "Whether to use the default AWS KMS key for encrypting environment variables"
  type        = bool
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encrypting environment variables (if not using default)"
  type        = string
}

variable "log_group_retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "lambda_timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_prefix" {
  description = "S3 prefix path"
  type        = string
}

variable "s3_suffix" {
  description = "S3 suffix path"
  type        = string
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for triggering the Lambda function daily"
  type        = string
}

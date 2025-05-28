##################################################################################
### Resource for Lambda                                                        ###
##################################################################################

resource "aws_lambda_function" "data_lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.iam_role_arn
  filename      = var.source_zip
  timeout       = var.lambda_timeout
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  kms_key_arn = var.use_default_kms ? null : var.kms_key_arn
  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_group_retention_in_days

  tags = var.tags
}

# Lambda Permission to allow S3 to invoke the Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name
  lambda_function {
    lambda_function_arn = aws_lambda_function.data_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_prefix
    filter_suffix       = var.s3_suffix
  }
}

##################################################################################
###                    Daily Schedule Trigger for Lambda                       ###
##################################################################################

resource "aws_cloudwatch_event_rule" "daily_lambda_trigger" {
  name                = "${var.function_name}-daily-trigger"
  description         = "Triggers ${var.function_name} Lambda function daily"
  schedule_expression = var.schedule_expression
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_lambda_trigger.name
  target_id = "${var.function_name}-daily-target"
  arn       = aws_lambda_function.data_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_lambda_trigger.arn
}
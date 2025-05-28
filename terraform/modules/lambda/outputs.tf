##################################################################################
### Outputs of Lambda                                                         ###
##################################################################################
output "lambda_log_group_name" {
  description = "Name of the CloudWatch Log Group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
  sensitive   = false
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.data_lambda.arn
  sensitive   = false
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for daily Lambda invocation"
  value       = aws_cloudwatch_event_rule.daily_lambda_trigger.arn
  sensitive   = false
}
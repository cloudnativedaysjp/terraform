output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.log_retention_lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.log_retention_lambda.arn
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "cloudwatch_rule_arn" {
  description = "ARN of the CloudWatch Event Rule"
  value       = aws_cloudwatch_event_rule.daily_trigger.arn
}
output "arn" {
  description = "ARN of the lambda function"
  value       = module.lambda.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the lambda function"
  value       = module.lambda.invoke_arn
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = module.lambda.qualified_arn
}

output "function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "role_name" {
  description = "Lambda IAM role name"
  value       = module.lambda.role_name
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = module.lambda.role_arn
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the log group"
  value       = module.lambda.cloudwatch_log_group_arn
}

output "cloudwatch_stream_arns" {
  description = "ARNs of the log streams"
  value       = module.lambda.cloudwatch_stream_arns
}

output "cloudwatch_log_group_name" {
  description = "Name of log group"
  value       = module.lambda.cloudwatch_log_group_name
}

output "cloudwatch_event_rule_ids" {
  description = "A list of CloudWatch event rule IDs"
  value       = module.lambda.cloudwatch_event_rule_ids
}

output "cloudwatch_event_rule_arns" {
  description = "A list of CloudWatch event rule ARNs"
  value       = module.lambda.cloudwatch_event_rule_arns
}

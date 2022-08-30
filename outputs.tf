output "arn" {
  description = "ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.this[0].arn : null
}

output "invoke_arn" {
  description = "Invoke ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.this[0].invoke_arn : null
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = local.enabled ? aws_lambda_function.this[0].qualified_arn : null
}

output "function_name" {
  description = "Lambda function name"
  value       = local.enabled ? aws_lambda_function.this[0].function_name : null
}

output "role_name" {
  description = "Lambda IAM role name"
  value       = local.enabled ? aws_iam_role.this[0].name : null
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = local.enabled ? aws_iam_role.this[0].arn : null
}

output "cloudwatch_log_group_arn" {
  value       = module.cloudwatch_log_group.log_group_arn
  description = "ARN of the log group"
}

output "cloudwatch_stream_arns" {
  value       = module.cloudwatch_log_group.stream_arns
  description = "ARNs of the log streams"
}

output "cloudwatch_log_group_name" {
  description = "Name of log group"
  value       = module.cloudwatch_log_group.log_group_name
}

output "cloudwatch_event_rule_ids" {
  description = "A list of CloudWatch event rule IDs"
  value       = try(values(aws_cloudwatch_event_rule.this)[*]["id"], null)
}

output "cloudwatch_event_rule_arns" {
  description = "A list of CloudWatch event rule ARNs"
  value       = try(values(aws_cloudwatch_event_rule.this)[*]["arn"], null)
}

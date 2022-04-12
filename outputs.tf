output "arn" {
  description = "ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.this[0].arn : null
}

output "invoke_arn" {
  description = "Inkoke ARN of the lambda function"
  value       = local.enabled ? aws_lambda_function.this[0].invoke_arn : null
}

output "qualified_arn" {
  description = "ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)"
  value       = local.enabled ? aws_lambda_function.this[0].qualified_arn : null
}

output "function_name" {
  description = "Lambda function name"
  value = local.enabled ? aws_lambda_function.this[0].function_name : null
}

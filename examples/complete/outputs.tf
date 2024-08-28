output "arn" {
  description = "ARN of the lambda function"
  value       = module.lambda.arn
}

output "function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "role_name" {
  description = "Lambda IAM role name"
  value       = module.lambda.role_name
}

output "cloudwatch_log_group_name" {
  description = "Name of Cloudwatch log group"
  value       = module.lambda.cloudwatch_log_group_name
}

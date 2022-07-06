variable "region" {
  type        = string
  description = "AWS Region"
}

variable "function_name" {
  type        = string
  description = "Unique name for the Lambda Function."
}

variable "handler" {
  type        = string
  description = "The function entrypoint in your code."
  default     = ""
}

variable "runtime" {
  type        = string
  description = "The runtime environment for the Lambda function you are uploading."
  default     = ""
}

variable "iam_policy_description" {
  type        = string
  description = "Description of the IAM policy for the Lambda IAM role"
  default     = "Minimum SSM read permissions for Lambda"
}

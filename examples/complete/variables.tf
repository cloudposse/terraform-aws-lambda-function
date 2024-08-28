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

variable "ephemeral_storage_size" {
  type        = number
  description = "The amount of storage available to the function at runtime. Defaults to 512."
  default     = 512
}

variable "source_mapping_enabled" {
  type        = bool
  description = "Enables the source mapping to set a Kinesis stream, a DynamoDB stream, or SQS queue as trigger for lambda."
  default     = false
}

variable "source_mapping_batch_size" {
  type        = number
  description = "(Optional) The largest number of records that Lambda will retrieve from your event source at the time of invocation. Defaults to 100 for DynamoDB and Kinesis, 10 for SQS."
  default     = 100
}

variable "source_mapping_arn" {
  type        = string
  description = "The event source ARN - can be a Kinesis stream, DynamoDB stream, or SQS queue."
  default     = null
}

variable "source_mapping_starting_position" {
  type        = string
  description = "The position in the stream where AWS Lambda should start reading. Must be one of AT_TIMESTAMP (Kinesis only), LATEST or TRIM_HORIZON if getting events from Kinesis or DynamoDB. Must not be provided if getting events from SQS. More information about these positions can be found in the AWS DynamoDB Streams API Reference and AWS Kinesis API Reference."
  default     = null
}

variable "source_mapping_starting_position_timestamp" {
  type        = string
  description = "(Optional) A timestamp in RFC3339 format of the data record which to start reading when using starting_position set to AT_TIMESTAMP. If a record with this exact timestamp does not exist, the next later record is chosen. If the timestamp is older than the current trim horizon, the oldest available record is chosen."
  default     = null
}

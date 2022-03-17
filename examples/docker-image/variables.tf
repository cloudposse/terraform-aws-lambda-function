variable "region" {
  type        = string
  description = "AWS Region"
}

variable "function_name" {
  description = "Unique name for the Lambda Function."
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code."
  default     = ""
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function you are uploading."
  default     = ""
  type        = string
}

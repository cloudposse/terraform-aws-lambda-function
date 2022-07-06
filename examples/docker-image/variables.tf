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

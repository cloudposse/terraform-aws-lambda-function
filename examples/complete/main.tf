module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [var.function_name]

  context = module.this.context
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "handler.js"
  output_path = "lambda_function.zip"
}

module "lambda" {
  source = "../.."

  filename      = data.archive_file.lambda_zip.output_path
  function_name = module.label.id
  handler       = var.handler
  runtime       = var.runtime

  context = module.this.context
}

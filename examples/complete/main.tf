locals {
  policy_name = module.this.id
}

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

module "iam_policy" {
  source = "cloudposse/iam-policy/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"

  iam_policy_statements = {
    ListMyBucket = {
      effect     = "Allow"
      actions    = ["s3:ListBucket"]
      resources  = ["arn:aws:s3:::test"]
      conditions = []
    }
    WriteMyBucket = {
      effect     = "Allow"
      actions    = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
      resources  = ["arn:aws:s3:::test/*"]
      conditions = []
    },
  }
}

resource "aws_iam_policy" "default" {
  name        = local.policy_name
  path        = "/"
  description = "My test policy"

  policy = module.iam_policy.json
}

module "lambda" {
  source = "../.."

  filename      = data.archive_file.lambda_zip.output_path
  function_name = module.label.id
  handler       = var.handler
  runtime       = var.runtime

  custom_iam_policy_arns = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
    local.policy_name, # aws_iam_policy.default.id,
  ]

  context = module.this.context

  depends_on = [
    aws_iam_policy.default,
  ]
}

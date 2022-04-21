locals {
  enabled = module.this.enabled

  # The policy name has to be at least 20 characters
  policy_name = "${module.this.id}-test-policy-addition"
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

resource "aws_iam_policy" "inside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name
  path        = "/"
  description = "My policy attached inside the lambda module"

  policy = module.iam_policy.json
}

resource "aws_iam_policy" "outside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name
  path        = "/"
  description = "My policy attached outside the lambda module"

  policy = module.iam_policy.json
}

resource "aws_iam_role_policy_attachment" "outside" {
  count      = local.enabled ? 1 : 0
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.outside[0].arn
}

module "lambda" {
  source = "../.."

  filename      = data.archive_file.lambda_zip.output_path
  function_name = module.label.id
  handler       = var.handler
  runtime       = var.runtime

  custom_iam_policy_arns = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
    local.policy_name, # aws_iam_policy.inside[0].id,
  ]

  context = module.this.context

  depends_on = [
    aws_iam_policy.inside,
  ]
}

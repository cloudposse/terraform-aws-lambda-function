locals {
  enabled = module.this.enabled

  # The policy name has to be at least 20 characters
  policy_name_inside  = "${module.label.id}-inside"
  policy_name_outside = "${module.label.id}-outside"

  policy_arn_prefix = format(
    "arn:%s:iam::%s:policy",
    data.aws_partition.current.partition,
    data.aws_caller_identity.current.account_id,
  )
  policy_arn_inside = format("%s/%s", local.policy_arn_prefix, local.policy_name_inside)
}

module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [var.function_name]

  context = module.this.context
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  count       = local.enabled ? 1 : 0
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

  context = module.this.context
}

resource "aws_iam_policy" "inside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name_inside
  path        = "/"
  description = "My policy attached inside the lambda module"

  policy = module.iam_policy.json
}

resource "aws_iam_policy" "outside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name_outside
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

  filename      = data.archive_file.lambda_zip[0].output_path
  function_name = module.label.id
  handler       = var.handler
  runtime       = var.runtime

  custom_iam_policy_arns = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
    local.policy_arn_inside,
    # aws_iam_policy.inside[0].id, # This will result in an error message and is why we use local.policy_name_inside
  ]

  context = module.this.context

  depends_on = [
    aws_iam_policy.inside,
  ]
}

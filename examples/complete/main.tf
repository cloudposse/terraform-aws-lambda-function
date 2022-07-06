locals {
  enabled = module.this.enabled

  # The policy name has to be at least 20 characters
  policy_name_inside  = "${module.label.id}-inside"
  policy_name_outside = "${module.label.id}-outside"

  policy_arn_prefix = format(
    "arn:%s:iam::%s:policy",
    join("", data.aws_partition.current.*.partition),
    join("", data.aws_caller_identity.current.*.account_id),
  )

  policy_arn_inside = format("%s/%s", local.policy_arn_prefix, local.policy_name_inside)

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [var.function_name]

  context = module.this.context
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "archive_file" "lambda_zip" {
  count       = local.enabled ? 1 : 0
  type        = "zip"
  source_file = "handler.js"
  output_path = "lambda_function.zip"
}

resource "aws_iam_policy" "inside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name_inside
  path        = "/"
  description = "The policy attached inside the Lambda module"

  policy = local.policy_json
}

resource "aws_iam_policy" "outside" {
  count       = local.enabled ? 1 : 0
  name        = local.policy_name_outside
  path        = "/"
  description = "The policy attached outside the Lambda module"

  policy = local.policy_json
}

resource "aws_iam_role_policy_attachment" "outside" {
  count      = local.enabled ? 1 : 0
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.outside[0].arn
}

module "lambda" {
  source = "../.."

  filename               = join("", data.archive_file.lambda_zip.*.output_path)
  function_name          = module.label.id
  handler                = var.handler
  runtime                = var.runtime
  iam_policy_description = var.iam_policy_description

  custom_iam_policy_arns = [
    "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
    local.policy_arn_inside,
    # aws_iam_policy.inside[0].id, # This will result in an error message and is why we use local.policy_name_inside
  ]

  context = module.this.context

  depends_on = [aws_iam_policy.inside]
}

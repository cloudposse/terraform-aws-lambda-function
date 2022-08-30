locals {
  cloudwatch_event_rules = local.enabled ? { for rule in var.cloudwatch_event_rules : rule.name => rule } : {}
}

module "event_rule_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.cloudwatch_event_rules

  attributes = [each.key]
  context    = module.this.context
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = local.cloudwatch_event_rules

  name                = module.event_rule_label[each.key].id
  schedule_expression = lookup(each.value, "schedule_expression", null)
  event_pattern       = lookup(each.value, "event_pattern", null)
  description         = lookup(each.value, "description", null) == null ? "Managed by Terraform" : each.value.description
  tags                = module.event_rule_label[each.key].tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = local.cloudwatch_event_rules

  target_id = module.event_rule_label[each.key].id
  rule      = aws_cloudwatch_event_rule.this[each.key].name
  arn       = join("", aws_lambda_function.this[*].arn)
}

resource "aws_lambda_permission" "this" {
  for_each = local.cloudwatch_event_rules

  statement_id  = module.event_rule_label[each.key].id
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = join("", aws_lambda_function.this[*].function_name)
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn
}

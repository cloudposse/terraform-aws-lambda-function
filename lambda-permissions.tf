resource "aws_lambda_permission" "invoke_function" {
  for_each = local.enabled ? { for i, permission in var.invoke_function_permissions : i => permission } : {}

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[0].function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}

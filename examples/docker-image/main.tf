data "aws_region" "this" {
  count = module.this.enabled ? 1 : 0
}

data "aws_caller_identity" "this" {
  count = module.this.enabled ? 1 : 0
}

module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [var.function_name]

  context = module.this.context
}

# Cloud Posse does NOT recommend building and pushing images to ECR via Terraform code. This is a job for your CI/CD
# pipeline. It is only done here for convenience and so that the example can be run locally.
module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.34.0"
  name    = module.label.id

  context = module.this.context
}

# Need to sleep for a few seconds after creating the ECR repository before we can push to it
resource "time_sleep" "wait_15_seconds" {
  count = module.this.enabled ? 1 : 0

  create_duration = "15s"

  depends_on = [module.ecr]
}

resource "null_resource" "docker_build" {
  count = module.this.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "docker build -t ${module.ecr.repository_url} ."
  }
}

resource "null_resource" "docker_login" {
  count = module.this.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${join("", data.aws_region.this.*.name)} | docker login --username AWS --password-stdin ${join("", data.aws_caller_identity.this.*.account_id)}.dkr.ecr.${join("", data.aws_region.this.*.name)}.amazonaws.com"
  }

  depends_on = [null_resource.docker_build]
}

resource "null_resource" "docker_push" {
  count = module.this.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "docker push ${module.ecr.repository_url}:latest"
  }

  depends_on = [
    time_sleep.wait_15_seconds,
    null_resource.docker_login
  ]
}

module "lambda" {
  source = "../.."

  function_name          = module.label.id
  image_uri              = "${module.ecr.repository_url}:latest"
  package_type           = "Image"
  iam_policy_description = var.iam_policy_description

  context = module.this.context

  depends_on = [null_resource.docker_push]
}

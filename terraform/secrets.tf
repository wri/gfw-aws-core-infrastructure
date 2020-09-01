##################
# Secrets
##################

resource "aws_secretsmanager_secret" "gfw_api_token" {
  name = "gfw-api/token"
}

resource "aws_secretsmanager_secret" "slack_gfw_sync" {
  name = "slack/gfw-sync"
}

resource "aws_secretsmanager_secret" "gfw-gee-export" {
  name = "gcs/gfw-gee-export"
}

resource "aws_secretsmanager_secret_version" "gfw_api_token" {
  secret_id     = aws_secretsmanager_secret.gfw_api_token.id
  secret_string = jsonencode({ "token" = var.gfw_api_token, "email" = "gfw-sync@wri.org" })
}

resource "aws_secretsmanager_secret_version" "slack_data_updates_hook" {
  secret_id     = aws_secretsmanager_secret.slack_gfw_sync.id
  secret_string = jsonencode({ "data-updates" = var.slack_data_updates_hook })
}

resource "aws_secretsmanager_secret_version" "gfw-gee-export" {
  secret_id     = aws_secretsmanager_secret.gfw-gee-export.id
  secret_string = var.gfw-gee-export_key
}


##################
# IAM policies
##################



data "template_file" "secrets_read_gfw-api-token" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.gfw_api_token.arn
  }
}

data "template_file" "secrets_read_slack-gfw-sync" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.slack_gfw_sync.arn
  }
}

data "template_file" "secrets_read_gfw-gee-export_key" {
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.gfw-gee-export.arn
  }
}

resource "aws_iam_policy" "secrets_read_gfw-api-token" {
  name   = "${local.project}-secrets_read_gfw-api-token"
  policy = data.template_file.secrets_read_gfw-api-token.rendered
}

resource "aws_iam_policy" "secrets_read_slack-gfw-sync" {
  name   = "${local.project}-secrets_read_slack-gfw-sync"
  policy = data.template_file.secrets_read_slack-gfw-sync.rendered
}

resource "aws_iam_policy" "secrets_read_gfw-gee-export_key" {
  name   = "${local.project}-secrets_read_gfw-gee-export_key"
  policy = data.template_file.secrets_read_gfw-gee-export_key.rendered
}
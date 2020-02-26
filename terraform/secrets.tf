resource "aws_secretsmanager_secret" "gfw_api_token" {
  name = "gfw-api/token"
}

resource "aws_secretsmanager_secret" "slack_gfw_sync" {
  name = "slack/gfw-sync"
}

resource "aws_secretsmanager_secret_version" "gfw_api_token" {
  secret_id     = aws_secretsmanager_secret.gfw_api_token.id
  secret_string = jsonencode({ "token" = var.gfw_api_token, "email" = "gfw-sync@wri.org" })
}

resource "aws_secretsmanager_secret_version" "slack_data_updates_hook" {
  secret_id     = aws_secretsmanager_secret.slack_gfw_sync.id
  secret_string = jsonencode({ "data-updates" = var.slack_data_updates_hook})
}
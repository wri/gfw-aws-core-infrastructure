##################
# Secrets
##################

resource "aws_secretsmanager_secret" "default" {
  count = length(var.secrets)
  name  = var.secrets[count.index].name
}

resource "aws_secretsmanager_secret_version" "default" {
  count         = length(var.secrets)
  secret_id     = aws_secretsmanager_secret.default[count.index].id
  secret_string = var.secrets[count.index].secret_string
}

data "template_file" "default" {
  count    = length(var.secrets)
  template = file("${path.root}/policies/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.default[count.index].arn
  }
}

resource "aws_iam_policy" "default" {
  count  = length(var.secrets)
  name   = replace("${var.project}-read-secret-${var.secrets[count.index].name}", "/", "-")
  policy = data.template_file.default[count.index].rendered
}


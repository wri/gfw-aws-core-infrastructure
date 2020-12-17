##################
# Secrets
##################

resource "aws_secretsmanager_secret" "default" {
  name = var.name
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = var.secret_string
}

data "template_file" "default" {
  template = file("${path.module}/template/iam_policy_secrets_read.json.tpl")
  vars = {
    secret_arn = aws_secretsmanager_secret.default.arn
  }
}

resource "aws_iam_policy" "default" {
  name   = replace("${var.project}-read-secret-${var.name}", "/", "-")
  policy = data.template_file.default.rendered
}


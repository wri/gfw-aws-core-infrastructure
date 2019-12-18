resource "aws_secretsmanager_secret" "gfw_api_token" {
  name = "gfw-api/token"
}

resource "aws_secretsmanager_secret_version" "gfw_api_token" {
  secret_id     = "${aws_secretsmanager_secret.gfw_api_token.id}"
  secret_string = jsonencode({"token"=var.gfw_api_token, "email"="gfw-sync@wri.org"})
}
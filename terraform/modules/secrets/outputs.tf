output "secret_arn" {
  value = aws_secretsmanager_secret.default.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.default.name
}


output "read_policy_arn" {
  value = aws_iam_policy.default.arn
}
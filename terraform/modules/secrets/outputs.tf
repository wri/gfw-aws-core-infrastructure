output "secret_arns" {
  value = aws_secretsmanager_secret.default[*].arn
}

output "secret_read_policy_arn" {
  value = aws_iam_policy.default[*].arn
}
output "security_group_id" {
  value       = aws_security_group.postgresql.id
  description = "Security group ID to access postgresql database"
}

output "secrets_postgresql-reader_arn" {
  value = aws_secretsmanager_secret.postgresql-reader.arn
}

output "secrets_postgresql-reader_policy_arn" {
  value = aws_iam_policy.secrets_postgresql-reader.arn
}

output "secrets_postgresql-writer_arn" {
  value = aws_secretsmanager_secret.postgresql-writer.arn
}

output "secrets_postgresql-writer_policy_arn" {
  value = aws_iam_policy.secrets_postgresql-writer.arn
}
output "security_group_id" {
  value       = aws_security_group.postgresql.id
  description = "Security group ID to access postgresql database"
}

output "secrets_postgresql-reader_arn" {
  value = module.read_only_secret.secret_arn
}

output "secrets_postgresql-reader_name" {
  value = module.read_only_secret.secret_name
}

output "secrets_postgresql-reader_policy_arn" {
  value = module.read_only_secret.read_policy_arn
}

output "secrets_postgresql-writer_arn" {
  value = module.write_secret.secret_arn
}

output "secrets_postgresql-writer_name" {
  value = module.write_secret.secret_name
}

output "secrets_postgresql-writer_policy_arn" {
  value = module.write_secret.read_policy_arn
}

output "aurora_cluster_instance_class" {
  value = aws_rds_cluster_instance.aurora_cluster_instance[0].instance_class
}
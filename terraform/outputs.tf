output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "pipelines_bucket" {
  value = module.pipeline_bucket.bucket_id
}

output "data-lake_bucket" {
  value = module.data-lake_bucket.bucket_id
}

output "tags" {
  value = local.tags
}

output "vpc_id" {
  value = module.vpc.id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  value = module.vpc.nat_gateway_ips
}

output "bastion_hostname" {
  value = module.vpc.bastion_hostname
}

output "cidr_block" {
  value = module.vpc.cidr_block
}

output "default_security_group_id" {
  value = module.firewall.default_security_group_id
}

output "webserver_security_group_id" {
  value = module.firewall.webserver_security_group_id
}

output "key_pair_tmaschler_gfw" {
  value = aws_key_pair.all["tmaschler_gfw"].key_name
}

output "key_pair_jterry_gfw" {
  value = aws_key_pair.all["jterry_gfw"].key_name
}

output "secrets_read-gfw-api-token_policy_arn" {
  value = module.api_token_secret.read_policy_arn
}

output "secrets_read-slack-gfw-sync_policy_arn" {
  value = module.slack_secret.read_policy_arn
}

output "secrets_read-gfw-gee-export_policy_arn" {
  value = module.gcs_gfw_gee_export_secret.read_policy_arn
}

output "secrets_read-gfw-api-token_arn" {
  value = module.api_token_secret.secret_arn
}

output "secrets_read-slack_gfw_sync_arn" {
  value = module.slack_secret.secret_arn
}

output "secrets_read-gfw-gee-export_arn" {
  value = module.gcs_gfw_gee_export_secret.secret_arn
}

output "iam_policy_s3_write_data-lake_arn" {
  value = module.data-lake_bucket.write_policy_arns[0]
}

output "iam_policy_s3_write_raw_data-lake_arn" {
  value = module.data-lake_bucket.write_policy_arns[1]
}

output "iam_policy_s3_write_pipelines_arn" {
  value = module.pipeline_bucket.write_policy_arns[0]
}

output "postgresql_security_group_id" {
  value       = module.postgresql.security_group_id
  description = "Security group ID to access postgresql database"
}

output "secrets_postgresql-reader_arn" {
  value = module.postgresql.secrets_postgresql-reader_arn
}

output "secrets_postgresql-reader_name" {
  value = module.postgresql.secrets_postgresql-reader_name
}

output "secrets_postgresql-reader_policy_arn" {
  value = module.postgresql.secrets_postgresql-reader_policy_arn
}

output "secrets_postgresql-writer_arn" {
  value = module.postgresql.secrets_postgresql-writer_arn
}

output "secrets_postgresql-writer_name" {
  value = module.postgresql.secrets_postgresql-writer_name
}

output "secrets_postgresql-writer_policy_arn" {
  value = module.postgresql.secrets_postgresql-writer_policy_arn
}

output "acm_certificate" {
  value = aws_acm_certificate.globalforestwatch[0].arn
}

output "aurora_cluster_instance_class" {
  value = module.postgresql.aurora_cluster_instance_class
}

output "emr_instance_profile_name" {
  value = aws_iam_instance_profile.emr_profile.name
}


output "emr_service_role_name" {
  value = aws_iam_role.iam_emr_service_role.name
}
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

output "key_pairs" {
  value = aws_key_pair.all
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


output "secrets_planet_api_key_arn" {
  value = module.planet_api_key_secret.secret_arn
}

output "secrets_planet_api_key_name" {
  value = module.planet_api_key_secret.secret_name
}

output "secrets_planet_api_key_policy_arn" {
  value = module.planet_api_key_secret.read_policy_arn
}

output "acm_certificate" {
  value = aws_acm_certificate.globalforestwatch_new[0].arn
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

output "sns_discovery_topic_arn" {
  value = module.sns.data_discovery_topic_arn
}

output "sns_discovery_publishers_group_arn" {
  value = module.sns.discovery_publishers_group_arn
}

output "sns_discovery_publishers_policy" {
  value = module.sns.rendered_policy
}

output "document_db_endpoint" {
  value = module.documentdb.endpoint
}

output "document_db_reader_endpoint" {
  value = module.documentdb.reader_endpoint
}

output "document_db_port" {
  value = module.documentdb.port
}

output "document_db_cluster_name" {
  value = module.documentdb.cluster_name
}

output "document_db_security_group_id" {
  value = module.documentdb.security_group_id
}

output "document_db_secrets_arn" {
  value = module.documentdb.secrets_documentdb_arn
}

output "document_db_secrets_policy_arn" {
  value = module.documentdb.secrets_documentdb_policy_arn
}

output "redis_replication_group_id" {
  value       = module.redis.replication_group_id
  description = "The ID of the ElastiCache Replication Group."
}

output "redis_replication_group_primary_endpoint_address" {
  value       = module.redis.replication_group_primary_endpoint_address
  description = "The address of the endpoint for the primary node in the replication group."
}


output "redis_replication_group_config_endpoint_address" {
  value       = module.redis.replication_group_configuration_endpoint_address
  description = "The address of the endpoint for the configuration node in the replication group."
}

output "redis_replication_group_member_clusters" {
  value       = module.redis.replication_group_member_clusters
  description = "The identifiers of all the nodes that are part of this replication group."
}

output "redis_replication_group_port" {
  value       = module.redis.replication_group_port
  description = "Port of the replication group."
}

output "redis_security_group_id" {
  description = "ID of the Elastic Cache Redis cluster Security Group"
  value       = module.redis.security_group_id
}

output "redis_security_group_arn" {
  description = "ARN of the Elastic Cache Redis cluster Security Group"
  value       = module.redis.security_group_arn
}

output "redis_security_group_name" {
  description = "Name of the Elastic Cache Redis cluster Security Group"
  value       = module.redis.security_group_name
}

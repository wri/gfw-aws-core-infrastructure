output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "pipelines_bucket" {
  value = aws_s3_bucket.pipelines.id
}

output "data-lake_bucket" {
  value = aws_s3_bucket.data-lake.id
}

output "tiles_bucket" {
  value = aws_s3_bucket.tiles.id
}

output "tags" {
  value = local.tags
}

output "lambda_layer_shapely_pyyaml_arn" {
  value = module.lambda_layers.shapely_pyyaml_arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
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
  value = aws_security_group.default.id
}

output "key_pair_tmaschler_gfw" {
  value = aws_key_pair.tmaschler_gfw.key_name
}

output "ephemeral_storage_batch_environment_arn" {
  value = module.batch_processing.ephemeral_storage_batch_environment_arn
}

output "secrets_read-gfw-api-token_policy_arn" {
  value = aws_iam_policy.secrets_read_gfw-api-token.arn
}

output "secrets_read-gfw-api-token_arn" {
  value = aws_secretsmanager_secret.gfw_api_token.arn
}

output "emr_instance_profile_name" {
  value = aws_iam_instance_profile.emr_profile.name
}

output "emr_service_role_name" {
  value = aws_iam_role.iam_emr_service_role.name
}

output "iam_policy_s3_write_data-lake_arn" {
  value = aws_iam_policy.s3_write_data-lake.arn
}

output "iam_policy_s3_write_pipelines_arn" {
  value = aws_iam_policy.s3_write_pipelines.arn
}

output "iam_policy_s3_write_tiles_arn" {
  value = aws_iam_policy.s3_write_tiles.arn
}
output "environment" {
  value       = var.environment
  description = "Environment of current state."
}

output "pipelines_bucket" {
  value = aws_s3_bucket.pipelines.id
}
//
//output "data-lake_bucket" {
//  value = aws_s3_bucket.data-lake.id
//}
//
//output "tiles_bucket" {
//  value = aws_s3_bucket.data-lake.id
//}

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

output "bastion_security_group_id" {
  value = module.vpc.bastion_security_group_id
}

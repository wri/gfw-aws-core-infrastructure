output "replication_group_id" {
  value       = aws_elasticache_replication_group.default.id
  description = "The ID of the ElastiCache Replication Group."
}

output "replication_group_primary_endpoint_address" {
  value       = aws_elasticache_replication_group.default.primary_endpoint_address
  description = "The address of the endpoint for the primary node in the replication group."
}

output "replication_group_configuration_endpoint_address" {
  value       = aws_elasticache_replication_group.default.configuration_endpoint_address
  description = "The address of the endpoint for the primary node in the replication group."
}

output "replication_group_member_clusters" {
  value       = aws_elasticache_replication_group.default.member_clusters
  description = "The identifiers of all the nodes that are part of this replication group."
}

output "replication_group_port" {
  value       = aws_elasticache_replication_group.default.port
  description = "Port of the replication group."
}

output "security_group_id" {
  description = "ID of the Elastic Cache Redis cluster Security Group"
  value       = aws_security_group.default.id
}

output "security_group_arn" {
  description = "ARN of the Elastic Cache Redis cluster Security Group"
  value       = aws_security_group.default.arn
}

output "security_group_name" {
  description = "Name of the Elastic Cache Redis cluster Security Group"
  value       = aws_security_group.default.name
}

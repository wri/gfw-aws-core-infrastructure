##################
# Cluster
##################

resource "aws_elasticache_replication_group" "default" {
  replication_group_id          = "${var.project_prefix}-redis-cluster"
  replication_group_description = "Redis cluster for GFW Data API"

  node_type            = var.redis_node_type
  port                 = var.redis_port
  parameter_group_name = aws_elasticache_parameter_group.default.name

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = "00:00-05:00"

  subnet_group_name          = aws_elasticache_subnet_group.default.name
  automatic_failover_enabled = var.num_replicas > 1 ? true : false

  cluster_mode {
    replicas_per_node_group = var.num_replicas
    num_node_groups         = var.num_node_groups
  }
}

resource "aws_elasticache_parameter_group" "default" {
  name        = "${var.project_prefix}-redis-params"
  family      = "redis5.0"
}

###############
# Subnet group
###############

resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.project_prefix}-redis-cluster"
  subnet_ids = var.private_subnet_ids
}


#################
# Security Group
#################

resource "aws_security_group" "default" {
  vpc_id                 = var.vpc_id
  description            = "Security Group for Elastic Cache Redis cluster"
  name                   = "${var.project_prefix}-elastic_cache_sg"
  revoke_rules_on_delete = true
  tags = merge(
    {
      Name = "${var.project_prefix}-sgElasticCacheRedis"
    },
    var.tags
  )
}


resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.default.id
}


resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.default.id
}
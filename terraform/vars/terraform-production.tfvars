environment             = "production"
backup_retention_period = 7
log_retention_period    = 30
rds_version             = "12.8"
rds_instance_class      = "db.r6g.large"
rds_instance_count      = 2
db_instance_class       = "db.t3.medium"
db_instance_count       = 1
redis_node_group_count  = 1
redis_replica_count     = 1
redis_node_type         = "cache.t2.micro"
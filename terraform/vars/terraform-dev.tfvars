environment             = "dev"
backup_retention_period = 1
log_retention_period    = 7
rds_version             = "12.8"
rds_instance_class      = "db.t3.medium"
rds_instance_count      = 1
db_instance_class       = "db.t3.medium"
db_instance_count       = 1
redis_node_group_count  = 1
redis_replica_count     = 0
redis_node_type         = "cache.t2.micro"
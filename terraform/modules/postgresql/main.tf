########################
## Cluster
########################


resource "aws_rds_cluster" "aurora_cluster" {

  cluster_identifier           = "${var.project}-aurora-cluster"
  engine                       = "aurora-postgresql"
  engine-version               = "11.6.postgresql_aurora.3.1.1"
  database_name                = var.rds_db_name
  master_username              = var.rds_user_name
  master_password              = var.rds_password
  backup_retention_period      = var.rds_backup_retention_period
  preferred_backup_window      = "14:00-15:00"
  preferred_maintenance_window = "sat:16:00-sat:17:00"
  db_subnet_group_name         = aws_db_subnet_group.default.name
  final_snapshot_identifier    = "${var.project}-aurora-cluster"
  vpc_security_group_ids = [
  aws_security_group.postgresql.id]
  availability_zones              = var.availability_zone_names
  copy_tags_to_snapshot           = true
  apply_immediately               = true
  port                            = var.rds_port
  enabled_cloudwatch_logs_exports = "postgresql"
  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Cluster"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }

}

# Only define one instance, other instances are defined using appautoscaling
resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

  count              = var.rds_instance_count
  identifier         = "${var.project}-aurora_instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.rds_instance_class
  //"db.t3.medium", "db.r5.xlarge"
  db_subnet_group_name  = aws_db_subnet_group.default.name
  publicly_accessible   = false
  apply_immediately     = true
  copy_tags_to_snapshot = true

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Instance-${count.index}"
    },
    var.tags
  )


  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_db_subnet_group" "default" {

  name       = "main"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Subnet-Group"
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora_cluster.cluster_identifier}/postgresql"
  retention_in_days = var.log_retention_period

  tags = merge(
    {
      Name = "${var.project}-Aurora-DB-Logs"
    },
    var.tags
  )
}

### Auto scaling

resource "aws_appautoscaling_target" "replicas" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.id}"
  min_capacity       = 1
  max_capacity       = 15
}

resource "aws_appautoscaling_policy" "replicas" {
  name               = "cpu-auto-scaling"
  service_namespace  = aws_appautoscaling_target.replicas.service_namespace
  scalable_dimension = aws_appautoscaling_target.replicas.scalable_dimension
  resource_id        = aws_appautoscaling_target.replicas.resource_id
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

#### Security Groups
# Allow access to aurora to all resources which are in the same security group

resource "aws_security_group" "postgresql" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.project}-sgPostgreSQL"
    },
    var.tags
  )
}


resource "aws_security_group_rule" "postgresql_ingress" {
  type              = "ingress"
  from_port         = var.rds_port
  to_port           = var.rds_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.postgresql.id
}

resource "aws_security_group_rule" "postgresql_egress" {
  type              = "egress"
  from_port         = var.rds_port
  to_port           = var.rds_port
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.postgresql.id
}


#### Add read-only user
###
provider "postgresql" {
  host            = aws_rds_cluster.aurora_cluster.endpoint
  port            = var.rds_port
  database        = var.rds_db_name
  username        = var.rds_user_name
  password        = var.rds_password
  sslmode         = "require"
  connect_timeout = 15
}

resource "postgresql_role" "gfw_reader" {
  name     = var.rds_user_name_ro
  login    = true
  password = var.rds_password_ro
}

resource "postgresql_default_privileges" "read_only_tables" {
  role     = postgresql_role.gfw_reader.name
  database = var.rds_db_name
  schema   = "public"
  owner       = var.rds_user_name
  object_type = "table"
  privileges  = ["SELECT"]
}

#### Secret Manager
resource "aws_secretsmanager_secret" "postgresql-reader" {
  description = "Connection string for Aurora PostgreSQL cluster"
  name        = "${var.project}-PostgreSQL-secret"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "postgresql-reader" {

  secret_id = aws_secretsmanager_secret.postgresql-reader.id
  secret_string = jsonencode({
    "username"             = var.rds_user_name_ro,
    "engine"               = "postgresql",
    "dbname"               = var.rds_db_name,
    "host"                 = aws_rds_cluster.aurora_cluster.reader_endpoint,
    "password"             = var.rds_password_ro,
    "port"                 = var.rds_port,
    "dbInstanceIdentifier" = aws_rds_cluster.aurora_cluster.cluster_identifier
  })


}


resource "aws_secretsmanager_secret" "postgresql-writer" {
  description = "Connection string for Aurora PostgreSQL cluster"
  name        = "${var.project}-PostgreSQL-secret"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "postgresql-writer" {

  secret_id = aws_secretsmanager_secret.postgresql-writer.id
  secret_string = jsonencode({
    "username"             = var.rds_user_name,
    "engine"               = "postgresql",
    "dbname"               = var.rds_db_name,
    "host"                 = aws_rds_cluster.aurora_cluster.endpoint,
    "password"             = var.rds_password,
    "port"                 = var.rds_port,
    "dbInstanceIdentifier" = aws_rds_cluster.aurora_cluster.cluster_identifier
  })
}
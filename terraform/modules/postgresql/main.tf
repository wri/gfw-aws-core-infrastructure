########################
## Cluster
########################


resource "aws_rds_cluster" "aurora_cluster" {

  cluster_identifier              = "gfw-aurora" # "${var.project}-aurora-cluster"
  engine                          = "aurora-postgresql"
  engine_version                  = var.rds_version
  database_name                   = var.rds_db_name
  master_username                 = var.rds_user_name
  master_password                 = var.rds_password
  backup_retention_period         = var.rds_backup_retention_period
  preferred_backup_window         = "14:00-15:00"
  preferred_maintenance_window    = "sat:16:00-sat:17:00"
  db_subnet_group_name            = aws_db_subnet_group.default.name
  final_snapshot_identifier       = "${var.project}-aurora-cluster"
  vpc_security_group_ids          = [aws_security_group.postgresql.id]
  availability_zones              = var.availability_zone_names
  copy_tags_to_snapshot           = true
  apply_immediately               = true
  port                            = var.rds_port
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
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

  count                        = var.rds_instance_count
  identifier                   = "${var.project}-aurora-instance-${count.index}"
  cluster_identifier           = aws_rds_cluster.aurora_cluster.id
  instance_class               = var.rds_instance_class
  engine                       = "aurora-postgresql"
  db_subnet_group_name         = aws_db_subnet_group.default.name
  publicly_accessible          = false
  apply_immediately            = true
  copy_tags_to_snapshot        = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  promotion_tier               = 1
  performance_insights_enabled = true

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

############
#### RDS Monitoring Role
############

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "${var.project}-rds_enhanced_monitoring-role"
  assume_role_policy = data.template_file.rds_enhanced_monitoring.rendered
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data template_file "rds_enhanced_monitoring" {

  template = file("${path.module}/templates/trust_service.json.tpl")
  vars = {
    service = "monitoring.rds"
  }
}

############
##### DB Subnet Group
############

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


##########
### Logging
##########


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

########
### Auto scaling
########


resource "aws_appautoscaling_target" "replicas" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.id}"
  min_capacity       = var.rds_instance_count
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


##########
#### Security Groups
##########


# Allow access to aurora to all resources which are in the same security group

resource "aws_security_group" "postgresql" {
  vpc_id                 = var.vpc_id
  name                   = "${var.project}-sgPostgreSQL"
  revoke_rules_on_delete = true
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

#########
#### Secret Manager
##########

module "read_only_secret" {
  source  = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project = var.project
  name    = "postgresql/read-only"
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

module "write_secret" {
  source  = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project = var.project
  name    = "postgresql/write"
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



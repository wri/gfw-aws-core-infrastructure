variable "project" {
  default     = "Global Forest Watch"
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "project_prefix" {
  type    = string
  default = "core"
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "application" {
  default     = "gfw-aws-core-infrastructure"
  type        = string
  description = "Name of the current application"
}

variable "dynamo_db_lock_table_name" {
  default     = "aws-locks"
  type        = string
  description = "Name of the lock table in Dynamo DB"
}

variable "gfw_api_token" {
  type        = string
  description = "Access token for the GFW/RW API."
}

variable "planet_api_key" {
  type        = string
  description = "Planet API Key"
}

variable "slack_data_updates_hook" {
  type        = string
  description = "Hook for Slack data-updates channel"
}


variable "wri_accounts" {
  default = {
    "gfw_production" : "401951483516"
    "gfw_staging" : "274931322839"
    "gfw_dev" : "563860007740"
    "gfw_pro" : "617001639586"
    "rw_api_production" : "534760749991"
    "rw_api_staging" : "843801476059"
    "rw_api_dev" : "842534099497"
    "wri" : "838255262149"
  }
}


variable "backup_retention_period" {
  type        = number
  description = "Time in days to keep RDS backup files"
}

variable "log_retention_period" {
  type        = number
  description = "Time in days to keep log files"
}

variable "rds_instance_class" {
  type        = string
  description = "RDS Aurora instance type for write node"
}

variable "rds_instance_count" {
  type        = number
  description = "RDS Aurora instance count"
}

variable "rds_password" {
  type        = string
  description = "Superuser password for RDS Aurora database"
}
variable "rds_password_ro" {
  type        = string
  description = "Read Only user password for RDS Aurora database"
}

variable "db_instance_class" {
  type = string
}

variable "db_instance_count" {
  type = number
}

variable "db_logs_exports" {
  type    = list(string)
  default = ["audit", "profiler"]
}

variable "redis_node_group_count" {
  type = number
}

variable "redis_replica_count" {
  type = number
}

variable "redis_node_type" {
  type = string
}


variable "gfw-gee-export_key" {
  type        = string
  description = "GCS key for service account"
}
variable "tmaschler_ip" {
  type        = string
  description = "Thomas' home IP address"
}
variable "jterry_ip" {
  type        = string
  description = "Justin's home IP address"
}
variable "dmannarino_ip" {
  type        = string
  description = "Daniel's home IP address"
}
variable "snegusse_ip" {
  type        = string
  description = "Solomon's home IP address"
}

variable "office_3sc_ip" {
  type = string
}

variable "vpn_3sc_ip" {
  type = string
}
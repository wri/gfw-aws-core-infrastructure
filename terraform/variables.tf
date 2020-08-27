variable "project" {
  default     = "Global Forest Watch"
  type        = string
  description = "A project namespace for the infrastructure."
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

variable "slack_data_updates_hook" {
  type        = string
  description = "Hook for Slack data-updates channel"
}

variable "production_account_number" {
  default     = "401951483516"
  type        = string
  description = "Account number of production account"
}

variable "staging_account_number" {
  default     = "274931322839"
  type        = string
  description = "Account number of production account"
}

variable "dev_account_number" {
  default     = "563860007740"
  type        = string
  description = "Account number of production account"
}


variable "rds_backup_retention_period" {
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

variable "rds_password" {
  type        = string
  description = "Superuser password for RDS Aurora database"
}
variable "rds_password_ro" {
  type        = string
  description = "Read Only user password for RDS Aurora database"
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
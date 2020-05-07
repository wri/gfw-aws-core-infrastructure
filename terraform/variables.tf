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

variable "cluster-name" {
  default = "gfw-k8s-cluster"
}


variable "webapps_node_group_instance_types" {
  type    = string
  default = "m5a.large"
}
variable "webapps_node_group_min_size" {
  type    = number
  default = 1
}
variable "webapps_node_group_max_size" {
  type    = number
  default = 1
}
variable "webapps_node_group_desired_size" {
  type    = number
  default = 1
}

variable "rds_backup_retention_period" {
  type = number
}

variable "log_retention_period" {
  type = number
}

variable "rds_instance_class" {
  type = string
}

variable "rds_password" { type = string }
variable "rds_password_ro" { type = string }
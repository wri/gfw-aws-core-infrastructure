variable "project_prefix" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "num_node_groups" {
  type = number
}
variable "num_replicas" {
  type = number
}
variable "snapshot_retention_limit" {
  type = number
}
variable "redis_port" {
  type    = number
  default = 6379
}
variable "redis_node_type" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_cidr_block" {
  type = string
}
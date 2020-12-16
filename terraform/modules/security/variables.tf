variable "project" {
  type = string
}

variable "ssh_cidr_blocks" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidre_block" {
  type = string
}
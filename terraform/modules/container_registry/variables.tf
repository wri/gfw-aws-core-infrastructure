# SOURCE: adopted from https://github.com/azavea/terraform-aws-ecr-repository
variable "repository_name" {
  default = "container-registry"
}

variable "lifecycle_policy" {
  default = ""
}

variable "tags" {}

variable "project" {}
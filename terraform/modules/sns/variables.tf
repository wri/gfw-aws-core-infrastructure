variable "bucket_suffix" {
  type = string
}

variable "project" {
  type        = string
  description = "Project name, used for naming resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to resources"
}
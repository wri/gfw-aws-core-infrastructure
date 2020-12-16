variable "project" {
  type = string
}
variable "requester_pays" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public" {
  type    = bool
  default = false
}

variable "bucket_name" {
  type = string
}

variable "lifecycle_rules" {
  type = list(
    object({
      id      = string
      enabled = bool
      prefix  = string
      transition = list(object({
        days          = number
        storage_class = string
      }))
      expiration = object({
        days = number
      })
    })
  )
  default = []
}

variable "public_folders" {
  type    = list(string)
  default = []
}

variable "read_roles" {
  type    = list(string)
  default = []
}

variable "write_policy_prefix" {
  type    = list(string)
  default = [""]
}
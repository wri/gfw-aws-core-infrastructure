variable "project" {
  type = string
}

variable "secrets" {
  type = list(object({
    name          = string
    secret_string = string
  }))
}
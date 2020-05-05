variable "project" {
  type = string
}

variable "name_suffix" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}


variable "data_api_listener_port" {
  type  = number
  default = 80
}

variable "data_api_container_port" {
  type  = number
  default = 80
}

variable "tile_cache_listener_port" {
  type  = number
  default = 7113
}

variable "tile_cache_container_port" {
  type  = number
  default = 80
}
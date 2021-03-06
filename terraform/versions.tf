terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.56, < 4.0"
      region  = "us-east-1"
    }
    local = {
      source = "hashicorp/local"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.13"
}

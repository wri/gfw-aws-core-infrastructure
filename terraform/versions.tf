terraform {
  required_version = "=0.13.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4, < 5" # when upgrading to 5.x, add storage_type=aurora-iopt1 to rds cluster in postgresql module (main.tf)
      region  = "us-east-1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

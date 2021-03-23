# Require TF version to be same as or greater than 0.12.13
terraform {
  backend "s3" {
    region         = "us-east-1"
    key            = "core.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}

module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  region      = var.aws_region
  project     = local.project
  tags        = local.tags
  security_group_ids = [
    module.firewall.default_security_group_id,
  module.postgresql.security_group_id]
  keys = values(aws_key_pair.all)[*].public_key
}


module "postgresql" {
  source                      = "./modules/postgresql"
  availability_zone_names     = [module.vpc.private_subnets[0].availability_zone, module.vpc.private_subnets[1].availability_zone, module.vpc.private_subnets[3].availability_zone]
  log_retention_period        = 30
  private_subnet_ids          = [module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id, module.vpc.private_subnets[3].id]
  project                     = local.project
  rds_backup_retention_period = var.rds_backup_retention_period
  rds_db_name                 = "geostore"
  rds_instance_class          = var.rds_instance_class
  rds_instance_count          = var.rds_instance_count
  rds_password                = var.rds_password
  rds_user_name               = "gfw"
  tags                        = local.tags
  vpc_id                      = module.vpc.id
  rds_password_ro             = var.rds_password_ro
  rds_port                    = 5432
  rds_user_name_ro            = "gfw_read_only"
}

module "sns" {
  source        = "./modules/sns"
  bucket_suffix = local.bucket_suffix
  project       = local.project
  tags          = local.tags
}

module "data-lake_bucket" {
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.0"
  bucket_name    = "gfw-data-lake${local.bucket_suffix}"
  project        = local.project
  requester_pays = false
  tags           = local.tags
  read_roles = [
    jsonencode(formatlist("arn:aws:iam::%s:root", values(var.wri_accounts))),
    jsonencode(formatlist("arn:aws:iam::%s:role/core-emr_profile",
  matchkeys(values(var.wri_accounts), keys(var.wri_accounts), ["gfw_production", "gfw_staging", "gfw_dev"])))]
  write_policy_prefix = ["", "*/raw/"]
}

module "pipeline_bucket" {
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.0"
  bucket_name = "gfw-pipelines${local.bucket_suffix}"
  project     = local.project
  lifecycle_rules = [
    {
      id      = "geotrellis_logs"
      enabled = true
      prefix  = "geotrellis/logs/"
      transition = [{
        days          = 30 # initially set to 3 days, but somehow this is no longer possible
        storage_class = "ONEZONE_IA"
        }, {
        days          = 60
        storage_class = "GLACIER"
      }]
      expiration = {
        days = 90
      }
    },
    {
      id      = "geotrellis_results"
      enabled = true
      prefix  = "geotrellis/results/"
      transition = [{
        days          = 30            # initally set to 7 days but this is somehow no longer possible
        storage_class = "STANDARD_IA" # or "ONEZONE_IA"
        }, {
        days          = 60
        storage_class = "GLACIER"
      }]
      expiration = {
        days = 90
      }
  }]
  tags           = local.tags
  public_folders = ["geotrellis/jars/", "geotrellis/results/", "fires/"]
}

module "data-lake-test-bucket" {
  count       = var.environment == "dev" ? 1 : 0
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.0"
  bucket_name = "gfw-data-lake-test"
  project     = local.project
  tags        = local.tags
}


module "pipeline-test-bucket" {
  count       = var.environment == "dev" ? 1 : 0
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.0"
  bucket_name = "gfw-pipelines-test"
  project     = local.project
  tags        = local.tags
}

module "firewall" {
  source          = "./modules/firewall"
  project         = local.project
  ssh_cidr_blocks = ["216.70.220.184/32", "${var.tmaschler_ip}/32", "${var.jterry_ip}/32", "${var.dmannarino_ip}/32"]
  description     = ["Office", "Thomas", "Justin", "Daniel"]
  tags            = local.tags
  vpc_cidre_block = module.vpc.cidr_block
  vpc_id          = module.vpc.id
}

module "api_token_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project       = local.project
  name          = "gfw-api/token"
  secret_string = jsonencode({ "token" = var.gfw_api_token, "email" = "gfw-sync@wri.org" })
}


module "slack_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project       = local.project
  name          = "slack/gfw-sync"
  secret_string = jsonencode({ "data-updates" = var.slack_data_updates_hook })
}

module "gcs_gfw_gee_export_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project       = local.project
  name          = "gcs/gfw-gee-export"
  secret_string = var.gfw-gee-export_key
}

module "planet_api_key_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.0"
  project       = local.project
  name          = "planet/api_key"
  secret_string = var.planet_api_key
}
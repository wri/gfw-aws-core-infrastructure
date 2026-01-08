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
  project     = var.project_prefix
  tags        = local.tags
  security_group_ids = [
    module.firewall.default_security_group_id,
    module.postgresql.security_group_id,
    module.documentdb.security_group_id,
    module.redis.security_group_id
  ]
  keys = values(aws_key_pair.all)[*].public_key
  //  keys = concat(values(aws_key_pair.all)[*].public_key, data.terraform_remote_state.fw_core.outputs.public_keys)
}

module "postgresql" {
  source                      = "./modules/postgresql"
  availability_zone_names     = [
    module.vpc.private_subnets[0].availability_zone,
    module.vpc.private_subnets[1].availability_zone,
    module.vpc.private_subnets[3].availability_zone
  ]
  log_retention_period        = var.log_retention_period
  private_subnet_ids          = [module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id, module.vpc.private_subnets[3].id]
  project                     = var.project_prefix
  rds_backup_retention_period = var.backup_retention_period
  rds_db_name                 = "geostore"
  rds_version                 = var.rds_version
  rds_instance_class          = var.rds_instance_class
  rds_instance_count          = var.rds_instance_count
  rds_password                = var.rds_password
  rds_user_name               = "gfw"
  tags = merge(
    {
      Job = "Geostore",
  }, local.tags)
  vpc_id           = module.vpc.id
  rds_password_ro  = var.rds_password_ro
  rds_port         = 5432
  rds_user_name_ro = "gfw_read_only"
}

module "sns" {
  source  = "./modules/sns"
  project = var.project_prefix
  tags = merge(
    {
      Job = "SNS Discovery Topic",
  }, local.tags)
}

module "data-lake_bucket" {
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.2.11"
  bucket_name    = "gfw-data-lake${local.bucket_suffix}"
  project        = var.project_prefix
  requester_pays = true
  tags           = merge({ Job = "Data Lake" }, local.tags)
  read_roles = [
    jsonencode(formatlist("arn:aws:iam::%s:root", values(var.wri_accounts))),
    jsonencode(formatlist("arn:aws:iam::%s:role/core-emr_profile",
    matchkeys(values(var.wri_accounts), keys(var.wri_accounts), ["gfw_production", "gfw_staging", "gfw_dev"])))
  ]
  write_policy_prefix = ["", "*/raw/"]

  # Add Intelligent-Tiering lifecycle rule
  lifecycle_rules = [
    {
      id      = "intelligent_tiering_transition"
      enabled = true
      prefix  = ""  # Apply to all objects
      transition = [{
        days          = 0  # Transition immediately
        storage_class = "INTELLIGENT_TIERING"
      }]
      expiration = {
        days = 36500  # ~100 years (module requires this field)
      }
    }
  ]
  enable_s3_logging_putobject_policy = false
}

module "pipeline_bucket" {
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.2.11"
  bucket_name    = "gfw-pipelines${local.bucket_suffix}"
  project        = var.project_prefix
  requester_pays = false
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
        days          = 30            # initially set to 7 days but this is somehow no longer possible
        storage_class = "STANDARD_IA" # or "ONEZONE_IA"
        }, {
        days          = 60
        storage_class = "GLACIER"
      }]
      expiration = {
        days = 90
      }
  }]
  tags           = merge({ Job = "Data Pipelines" }, local.tags)
  public_folders = ["geotrellis/jars/", "geotrellis/results/", "geotrellis/bootstrap/", "fires/"]
  enable_s3_logging_putobject_policy = true
}

module "data-lake-test-bucket" {
  count          = var.environment == "dev" ? 1 : 0
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.2.11"
  bucket_name    = "gfw-data-lake-test"
  requester_pays = true
  project        = var.project_prefix
  tags           = merge({ Job = "Data Lake" }, local.tags)
  enable_s3_logging_putobject_policy = false
}

module "pipeline-test-bucket" {
  count          = var.environment == "dev" ? 1 : 0
  source         = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/storage?ref=v0.4.2.11"
  bucket_name    = "gfw-pipelines-test"
  requester_pays = false
  project        = var.project_prefix
  tags           = merge({ Job = "Data Pipelines" }, local.tags)
  enable_s3_logging_putobject_policy = false
}

module "firewall" {
  source          = "./modules/firewall"
  project         = var.project_prefix
  ssh_cidr_blocks = ["54.173.196.8/32", "216.70.220.184/32", "${var.jterry_ip}/32", "${var.dmannarino_ip}/32", "${var.snegusse_ip}/32", "${var.gtempus_ip}/32", "86.143.108.56/32", "92.234.149.30/32", "212.35.238.28/32", "90.206.63.59/32"]
  description     = ["3SC Office VPN", "Office", "Justin", "Daniel", "Solomon", "Gary", "Dockerised", "Dockerised2", "Owen", "Edward"]
  tags            = merge({ Job = "Firewall" }, local.tags)
  vpc_cidre_block = module.vpc.cidr_block
  vpc_id          = module.vpc.id
  environment     = var.environment
}

module "api_token_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.2.11"
  project       = var.project_prefix
  name          = "gfw-api/token"
  secret_string = jsonencode({ "token" = var.gfw_api_token, "email" = "gfw-sync@wri.org" })
}

module "slack_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.2.11"
  project       = var.project_prefix
  name          = "slack/gfw-sync"
  secret_string = jsonencode({ "data-updates" = var.slack_data_updates_hook })
}

module "gcs_gfw_gee_export_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.2.11"
  project       = var.project_prefix
  name          = "gcs/gfw-gee-export"
  secret_string = var.gfw-gee-export_key
}

module "planet_api_key_secret" {
  source        = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/secrets?ref=v0.4.2.11"
  project       = var.project_prefix
  name          = "planet/api_key"
  secret_string = var.planet_api_key
}

module "documentdb" {
  source                          = "./modules/document_db"
  log_retention_period            = var.log_retention_period
  private_subnet_ids              = module.vpc.private_subnet_ids
  project                         = var.project_prefix
  backup_retention_period         = var.backup_retention_period
  instance_class                  = var.db_instance_class
  cluster_size                    = var.db_instance_count
  master_username                 = "wri" # superuser, create app specific users at project level
  tags                            = merge(local.tags, {Project = "Forest Watcher"}) # Only Forest Watcher is using Document DB and should cover the costs
  vpc_id                          = module.vpc.id
  vpc_cidr_block                  = module.vpc.cidr_block
  engine_version                  = "3.6.0"
  enabled_cloudwatch_logs_exports = var.db_logs_exports
  cluster_parameters = [
    {
      apply_method = "pending-reboot"
      name         = "tls"
      value        = "disabled"
  }]
}

module "redis" {
  source                   = "./modules/elastic_cache"
  project_prefix           = var.project_prefix
  num_node_groups          = var.redis_node_group_count
  num_replicas             = var.redis_replica_count
  redis_node_type          = var.redis_node_type
  vpc_cidr_block           = module.vpc.cidr_block
  vpc_id                   = module.vpc.id
  private_subnet_ids       = module.vpc.private_subnet_ids
  snapshot_retention_limit = var.backup_retention_period
  tags                     = local.tags
}

module "ssm" {
  source      = "git::https://github.com/wri/gfw-terraform-modules.git//terraform/modules/ssm?ref=v0.4.2.12"
  environment = var.environment
  namespace   = "gfw-aws-core-infra"
  contract = {
    acm_certificate_arn                 = aws_acm_certificate.globalforestwatch_new[0].arn
    data_lake_bucket_name               = module.data-lake_bucket.bucket_id
    gfw_gee_export_secret_arn           = module.gcs_gfw_gee_export_secret.secret_arn
    gfw_pipelines_bucket_name           = module.pipeline_bucket.bucket_id
    gfw_data_api_token_arn              = module.api_token_secret.secret_arn
    gfw_data_api_token_read_policy_arn  = module.api_token_secret.read_policy_arn
    planet_secret_arn                   = module.planet_api_key_secret.secret_arn
    planet_secret_policy_arn            = module.planet_api_key_secret.read_policy_arn
    postgresql_reader_secret_arn        = module.postgresql.secrets_postgresql-reader_arn
    postgresql_reader_secret_policy_arn = module.postgresql.secrets_postgresql-reader_policy_arn
    postgresql_writer_secret_arn        = module.postgresql.secrets_postgresql-writer_arn
    postgresql_security_group_id        = module.postgresql.security_group_id
    private_subnet_ids                  = module.vpc.private_subnet_ids
    public_subnet_ids                   = module.vpc.public_subnet_ids
    tags                                = local.tags
    vpc_id                              = module.vpc.id
  }
  lists = {}
  strings = {}
  secure_strings = {}
}

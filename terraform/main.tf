# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.24"
  backend "s3" {
    region         = "us-east-1"
    key            = "core.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.56.0"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}


module "data-lake_policy" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=0.2.0"
  source_documents = [
    data.template_file.data-lake_bucket_policy_public.rendered,
    data.template_file.data-lake_bucket_policy_emr_production.rendered,
    data.template_file.data-lake_bucket_policy_emr_staging.rendered,
    data.template_file.data-lake_bucket_policy_emr_dev.rendered
  ]
}


module "vpc" {
  source      = "./modules/vpc"
  environment = var.environment
  region      = var.aws_region
  key_name    = aws_key_pair.tmaschler_gfw.key_name
  bastion_ami = data.aws_ami.amazon_linux_ami.id
  project     = local.project
  tags        = local.tags
  security_group_ids = [
  aws_security_group.default.id]

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
  rds_instance_count          = 1
  rds_password                = var.rds_password
  rds_user_name               = "gfw"
  tags                        = local.tags
  vpc_id                      = module.vpc.id
  rds_password_ro             = var.rds_password_ro
  rds_port                    = 5432
  rds_user_name_ro            = "gfw_read_only"
}

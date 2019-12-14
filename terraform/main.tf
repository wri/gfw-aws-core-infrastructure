# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
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
  version = "~> 2.36.0"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}

module "lambda_layers" {
  source    = "./modules/lambda_layers"
  s3_bucket = local.tf_state_bucket
  project   = local.project
}

module "tile_cache" {
  source  = "./modules/tile_cache"
  project = local.project
  tags    = local.tags
}

module "tiles_policy" {
  source = "git::https://github.com/techfishio/terraform-aws-iam-policy-document-aggregator.git?ref=rf/GH-11--upgrade-to-terraform-0_12"
  //    source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=master"
  source_documents = [
    data.template_file.tiles_bucket_policy_public.rendered,
    data.template_file.tiles_bucket_policy_cloudfront.rendered,
    data.template_file.tiles_bucket_policy_lambda.rendered
  ]
}
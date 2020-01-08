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
  //    source = "git::https://github.com/cloudposse/terraform-aws-iam-policy-document-aggregator.git?ref=master"
  source = "git::https://github.com/techfishio/terraform-aws-iam-policy-document-aggregator.git?ref=rf/GH-11--upgrade-to-terraform-0_12"
  source_documents = [
    data.template_file.tiles_bucket_policy_public.rendered,
    data.template_file.tiles_bucket_policy_cloudfront.rendered,
    data.template_file.tiles_bucket_policy_lambda.rendered
  ]
}

module "vpc" {
  source             = "./modules/vpc"
  region             = var.aws_region
  key_name           = aws_key_pair.tmaschler_gfw.key_name
  bastion_ami        = data.aws_ami.amazon_linux_ami.id
  project            = local.project
  tags               = local.tags
  security_group_ids = [aws_security_group.default.id]
  //  user_data = data.template_file.ssh_keys_ec2_user.rendered
}

module "batch_processing" {
  source                         = "./modules/batch_processing"
  project                        = local.project
  key_pair                       = aws_key_pair.tmaschler_gfw.key_name
  subnets                        = module.vpc.public_subnet_ids
  launch_template_id             = aws_launch_template.ecs-optimized-ephemeral-storage-mounted.id
  launch_template_latest_version = aws_launch_template.ecs-optimized-ephemeral-storage-mounted.latest_version
  tags                           = local.tags
  vpc_id                         = module.vpc.id
  vpc_cidr_blocks                = [module.vpc.cidr_block]
  s3_data-lake_write             = aws_iam_policy.s3_write_data-lake.arn
  s3_tiles_write                 = aws_iam_policy.s3_write_tiles.arn
  s3_pipelines_write             = aws_iam_policy.s3_write_pipelines.arn
}